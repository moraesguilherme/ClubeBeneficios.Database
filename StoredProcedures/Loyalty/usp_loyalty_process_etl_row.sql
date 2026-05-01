CREATE   PROCEDURE [dbo].[usp_loyalty_process_etl_row]
    @ImportRowId bigint,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @ClientId uniqueidentifier,
        @CreatedEvents int = 0,
        @IgnoredRules int = 0,
        @FailedRules int = 0;

    SELECT
        @ClientId = m.client_id
    FROM dbo.etl_import_rows r
    INNER JOIN dbo.etl_import_row_matches m
        ON m.import_row_id = r.id
    WHERE r.id = @ImportRowId;

    IF @ClientId IS NULL
    BEGIN
        INSERT INTO dbo.loyalty_processing_log
        (
            id,
            import_row_id,
            client_id,
            processing_stage,
            processing_status,
            message,
            loyalty_event_id,
            created_at
        )
        VALUES
        (
            NEWID(),
            @ImportRowId,
            NULL,
            'eligibility_check',
            'failed',
            'Linha ETL sem client_id reconciliado.',
            NULL,
            SYSUTCDATETIME()
        );

        SELECT
            import_row_id = @ImportRowId,
            client_id = CAST(NULL AS uniqueidentifier),
            created_events = 0,
            ignored_rules = 0,
            failed_rules = 1;

        RETURN;
    END;

    DECLARE @Calculated TABLE
    (
        import_row_id bigint,
        client_id uniqueidentifier,
        rule_id uniqueidentifier,
        rule_name varchar(150),
        condition_id uniqueidentifier,
        calculation_type varchar(50),
        points_delta int,
        description varchar(1500)
    );

    INSERT INTO @Calculated
    EXEC dbo.usp_loyalty_calculate_points_for_etl_row
        @ImportRowId = @ImportRowId;

    IF NOT EXISTS (SELECT 1 FROM @Calculated)
    BEGIN
        INSERT INTO dbo.loyalty_processing_log
        (
            id,
            import_row_id,
            client_id,
            processing_stage,
            processing_status,
            message,
            loyalty_event_id,
            created_at
        )
        VALUES
        (
            NEWID(),
            @ImportRowId,
            @ClientId,
            'rule_evaluation',
            'ignored',
            'Nenhuma regra de pontuacao aplicavel para a linha ETL.',
            NULL,
            SYSUTCDATETIME()
        );

        SELECT
            import_row_id = @ImportRowId,
            client_id = @ClientId,
            created_events = 0,
            ignored_rules = 1,
            failed_rules = 0;

        RETURN;
    END;

    DECLARE
        @RuleId uniqueidentifier,
        @PointsDelta int,
        @Description varchar(1500),
        @EventId uniqueidentifier;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            rule_id,
            points_delta,
            description
        FROM @Calculated;

    OPEN cur;
    FETCH NEXT FROM cur INTO @RuleId, @PointsDelta, @Description;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM dbo.customer_loyalty_events
            WHERE source_type = 'etl_payment_row'
              AND source_id = CONVERT(varchar(100), @ImportRowId)
              AND rule_id = @RuleId
        )
        BEGIN
            SET @IgnoredRules += 1;

            INSERT INTO dbo.loyalty_processing_log
            (
                id,
                import_row_id,
                client_id,
                processing_stage,
                processing_status,
                message,
                loyalty_event_id,
                created_at
            )
            VALUES
            (
                NEWID(),
                @ImportRowId,
                @ClientId,
                'event_creation',
                'ignored',
                'Evento ja existente para esta linha ETL e regra.',
                NULL,
                SYSUTCDATETIME()
            );
        END
        ELSE
        BEGIN
            BEGIN TRY
                SET @EventId = NEWID();

                EXEC dbo.usp_loyalty_event_create_from_etl_row
                    @EventId = @EventId,
                    @ImportRowId = @ImportRowId,
                    @ClientId = @ClientId,
                    @EventType = 'payment_confirmed',
                    @MovementType = 'credit',
                    @PointsDelta = @PointsDelta,
                    @RuleId = @RuleId,
                    @CampaignId = NULL,
                    @PaymentReference = NULL,
                    @Description = @Description,
                    @OccurredAt = NULL,
                    @EffectiveAt = NULL,
                    @ExpiresAt = NULL,
                    @CreatedByUserId = @CreatedByUserId;

                SET @CreatedEvents += 1;

                INSERT INTO dbo.loyalty_processing_log
                (
                    id,
                    import_row_id,
                    client_id,
                    processing_stage,
                    processing_status,
                    message,
                    loyalty_event_id,
                    created_at
                )
                VALUES
                (
                    NEWID(),
                    @ImportRowId,
                    @ClientId,
                    'event_creation',
                    'processed',
                    CONCAT('Evento criado para regra ', CONVERT(varchar(36), @RuleId), '. Pontos: ', @PointsDelta),
                    @EventId,
                    SYSUTCDATETIME()
                );
            END TRY
            BEGIN CATCH
                SET @FailedRules += 1;

                INSERT INTO dbo.loyalty_processing_log
                (
                    id,
                    import_row_id,
                    client_id,
                    processing_stage,
                    processing_status,
                    message,
                    loyalty_event_id,
                    created_at
                )
                VALUES
                (
                    NEWID(),
                    @ImportRowId,
                    @ClientId,
                    'event_creation',
                    'failed',
                    ERROR_MESSAGE(),
                    NULL,
                    SYSUTCDATETIME()
                );
            END CATCH;
        END;

        FETCH NEXT FROM cur INTO @RuleId, @PointsDelta, @Description;
    END;

    CLOSE cur;
    DEALLOCATE cur;

    IF @CreatedEvents > 0
    BEGIN
        EXEC dbo.usp_customer_loyalty_balance_rebuild
            @ClientId = @ClientId;

        EXEC dbo.usp_loyalty_score_rebuild_by_client
            @ClientId = @ClientId;

        EXEC dbo.usp_loyalty_reclassify_client_by_latest_score
            @ClientId = @ClientId,
            @CreatedByUserId = @CreatedByUserId;

        INSERT INTO dbo.loyalty_processing_log
        (
            id,
            import_row_id,
            client_id,
            processing_stage,
            processing_status,
            message,
            loyalty_event_id,
            created_at
        )
        VALUES
        (
            NEWID(),
            @ImportRowId,
            @ClientId,
            'finalization',
            'processed',
            'Saldo, score e nivel recalculados.',
            NULL,
            SYSUTCDATETIME()
        );
    END;

    SELECT
        import_row_id = @ImportRowId,
        client_id = @ClientId,
        created_events = @CreatedEvents,
        ignored_rules = @IgnoredRules,
        failed_rules = @FailedRules;
END;
GO

