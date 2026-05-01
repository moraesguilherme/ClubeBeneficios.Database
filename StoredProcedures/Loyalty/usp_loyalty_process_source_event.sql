CREATE   PROCEDURE [dbo].[usp_loyalty_process_source_event]
    @ClientId uniqueidentifier,
    @SourceType varchar(50),
    @ConditionType varchar(50),
    @SourceId varchar(100),
    @SourceReference varchar(150),
    @EventType varchar(50),
    @OccurredAt datetime2(7) = NULL,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @CreatedEvents int = 0,
        @IgnoredRules int = 0,
        @FailedRules int = 0;

    DECLARE @Calculated TABLE
    (
        client_id uniqueidentifier,
        source_type varchar(50),
        source_id varchar(100),
        source_reference varchar(150),
        rule_id uniqueidentifier,
        rule_name varchar(150),
        condition_id uniqueidentifier,
        calculation_type varchar(50),
        points_delta int,
        description varchar(1500)
    );

    INSERT INTO @Calculated
    EXEC dbo.usp_loyalty_calculate_points_for_source_event
        @ClientId = @ClientId,
        @SourceType = @SourceType,
        @ConditionType = @ConditionType,
        @SourceId = @SourceId,
        @SourceReference = @SourceReference;

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
            NULL,
            @ClientId,
            'rule_evaluation',
            'ignored',
            CONCAT('Nenhuma regra aplicavel para ', @SourceType, ' / ', @ConditionType, '.'),
            NULL,
            SYSUTCDATETIME()
        );

        SELECT
            client_id = @ClientId,
            source_type = @SourceType,
            source_id = @SourceId,
            source_reference = @SourceReference,
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
            WHERE client_id = @ClientId
              AND source_type = @SourceType
              AND source_id = @SourceId
              AND ISNULL(source_reference, '') = ISNULL(@SourceReference, '')
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
                NULL,
                @ClientId,
                'event_creation',
                'ignored',
                'Evento ja existente para esta origem/regra/referencia.',
                NULL,
                SYSUTCDATETIME()
            );
        END
        ELSE
        BEGIN
            BEGIN TRY
                SET @EventId = NEWID();

                EXEC dbo.usp_loyalty_event_create_from_source
                    @EventId = @EventId,
                    @ClientId = @ClientId,
                    @EventType = @EventType,
                    @MovementType = 'credit',
                    @SourceType = @SourceType,
                    @SourceId = @SourceId,
                    @SourceReference = @SourceReference,
                    @PointsDelta = @PointsDelta,
                    @RuleId = @RuleId,
                    @CampaignId = NULL,
                    @RewardId = NULL,
                    @AdjustmentId = NULL,
                    @MonetaryAmount = NULL,
                    @PaymentMethod = NULL,
                    @PaymentReference = NULL,
                    @Description = @Description,
                    @OccurredAt = @OccurredAt,
                    @EffectiveAt = @OccurredAt,
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
                    NULL,
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
                    NULL,
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
        EXEC dbo.usp_loyalty_client_full_rebuild
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
            NULL,
            @ClientId,
            'finalization',
            'processed',
            'Saldo, score e nivel recalculados apos evento de cliente/pet.',
            NULL,
            SYSUTCDATETIME()
        );
    END;

    SELECT
        client_id = @ClientId,
        source_type = @SourceType,
        source_id = @SourceId,
        source_reference = @SourceReference,
        created_events = @CreatedEvents,
        ignored_rules = @IgnoredRules,
        failed_rules = @FailedRules;
END;
GO

