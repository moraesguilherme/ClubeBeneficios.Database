CREATE   PROCEDURE [dbo].[usp_loyalty_process_pending_etl_rows]
    @BatchSize int = 200,
    @CreatedByUserId uniqueidentifier = NULL,
    @RunType varchar(30) = 'manual'
AS
BEGIN
    SET NOCOUNT ON;

    IF @BatchSize IS NULL OR @BatchSize < 1
        SET @BatchSize = 200;

    DECLARE
        @StartedAt datetime2(7) = SYSUTCDATETIME(),
        @FinishedAt datetime2(7),
        @ImportRowId bigint,
        @ClientId uniqueidentifier,
        @CreatedEvents int,
        @ProcessedRows int = 0,
        @TotalCreatedEvents int = 0,
        @IgnoredRows int = 0,
        @FailedRows int = 0;

	DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
		SELECT TOP (@BatchSize)
			r.id
		FROM dbo.etl_import_rows r
		INNER JOIN dbo.clients c
			ON REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(c.document, ''), '.', ''), '-', ''), '/', ''), ' ', '')
			 = REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(r.customer_document_raw, ''), '.', ''), '-', ''), '/', ''), ' ', '')
		WHERE r.is_current = 1
		  AND r.status IN ('processed', 'matched')
		  AND LOWER(ISNULL(r.payment_status_raw, '')) IN ('pago', 'paid')
		  AND r.occurred_at IS NOT NULL
		  AND
			(
				EXISTS
				(
					SELECT 1
					FROM dbo.loyalty_rules lr
					INNER JOIN dbo.loyalty_rule_conditions rc
						ON rc.rule_id = lr.id
					WHERE lr.status = 'active'
					  AND lr.category IN ('scoring', 'points')
					  AND ISNULL(rc.source_type, 'etl_payment_row') = 'etl_payment_row'
					  AND rc.condition_type IN ('paid_amount', 'payment_method')
					  AND NOT EXISTS
					  (
						  SELECT 1
						  FROM dbo.customer_loyalty_events e
						  WHERE e.source_type = 'etl_payment_row'
							AND e.source_reference = r.external_row_key
							AND e.rule_id = lr.id
					  )
				)
				OR EXISTS
				(
					SELECT 1
					FROM dbo.loyalty_rules lr
					INNER JOIN dbo.loyalty_rule_conditions rc
						ON rc.rule_id = lr.id
					WHERE lr.status = 'active'
					  AND lr.category IN ('scoring', 'points')
					  AND ISNULL(rc.source_type, 'etl_payment_row') = 'etl_payment_row'
					  AND rc.condition_type IN ('service', 'service_type')
					  AND NOT EXISTS
					  (
						  SELECT 1
						  FROM dbo.customer_loyalty_events e
						  WHERE e.source_type = 'etl_payment_row'
							AND e.source_id = CONVERT(varchar(100), r.id)
							AND e.rule_id = lr.id
					  )
				)
			)
		ORDER BY r.id ASC;

    OPEN cur;
    FETCH NEXT FROM cur INTO @ImportRowId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SET @ClientId = NULL;
            SET @CreatedEvents = 0;

            SELECT TOP 1
                @ClientId = c.id
            FROM dbo.etl_import_rows r
            INNER JOIN dbo.clients c
                ON REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(c.document, ''), '.', ''), '-', ''), '/', ''), ' ', '')
                 = REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(r.customer_document_raw, ''), '.', ''), '-', ''), '/', ''), ' ', '')
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
                    'ignored',
                    'Linha ETL ignorada: cliente não cadastrado no Clube de Benefícios pelo documento informado.',
                    NULL,
                    SYSUTCDATETIME()
                );

                SET @IgnoredRows += 1;
                SET @ProcessedRows += 1;

                FETCH NEXT FROM cur INTO @ImportRowId;
                CONTINUE;
            END;

			DECLARE @SourceReference varchar(300);

			SELECT
				@SourceReference = r.external_row_key
			FROM dbo.etl_import_rows r
			WHERE r.id = @ImportRowId;

			;WITH SourceRows AS
			(
				SELECT
					r.*,
					normalized_payment_method =
						CASE LOWER(ISNULL(r.payment_method_raw, ''))
							WHEN 'pix' THEN 'pix'
							WHEN 'dinheiro' THEN 'cash'
							WHEN 'cash' THEN 'cash'
							WHEN 'debito' THEN 'debit_card'
							WHEN 'débito' THEN 'debit_card'
							WHEN 'credito' THEN 'credit_card'
							WHEN 'crédito' THEN 'credit_card'
							WHEN 'boleto' THEN 'boleto'
							WHEN 'transferencia' THEN 'bank_transfer'
							WHEN 'transferência' THEN 'bank_transfer'
							ELSE 'other'
						END
				FROM dbo.etl_import_rows r
				WHERE r.external_row_key = @SourceReference
			),
			PaymentSource AS
			(
				SELECT TOP 1 *
				FROM SourceRows
				ORDER BY id ASC
			),
			PaymentCandidateEvents AS
			(
				SELECT
					source_id = r.id,
					rule_id = lr.id,
					condition_type = rc.condition_type,
					calculated_points = CAST(
						CASE
							WHEN rc.currency_unit_amount IS NOT NULL
								 AND rc.currency_unit_amount > 0
								 AND rc.points_value IS NOT NULL
								THEN FLOOR(ISNULL(r.net_amount, r.gross_amount) / rc.currency_unit_amount) * rc.points_value

							WHEN rc.multiplier_value IS NOT NULL
								THEN ISNULL(r.net_amount, r.gross_amount) * rc.multiplier_value

							WHEN rc.points_value IS NOT NULL
								THEN rc.points_value

							ELSE 0
						END
					AS int),
					monetary_amount = ISNULL(r.net_amount, r.gross_amount),
					r.normalized_payment_method,
					r.external_row_key,
					r.service_type_raw,
					pet_name_raw = 'Pagamento',
					r.occurred_at
				FROM PaymentSource r
				INNER JOIN dbo.loyalty_rules lr
					ON lr.status = 'active'
				   AND lr.category IN ('scoring', 'points')
				INNER JOIN dbo.loyalty_rule_conditions rc
					ON rc.rule_id = lr.id
				WHERE ISNULL(rc.source_type, 'etl_payment_row') = 'etl_payment_row'
				  AND rc.condition_type IN ('paid_amount', 'payment_method')
				  AND (rc.service_type IS NULL OR rc.service_type = '' OR LOWER(rc.service_type) = LOWER(r.service_type_raw))
				  AND (rc.plan_type IS NULL OR rc.plan_type = '' OR LOWER(rc.plan_type) = LOWER(ISNULL(r.plan_name_raw, '')))
				  AND (rc.package_type IS NULL OR rc.package_type = '' OR LOWER(rc.package_type) = LOWER(ISNULL(r.package_name_raw, '')))
				  AND (rc.payment_method IS NULL OR rc.payment_method = '' OR LOWER(rc.payment_method) = LOWER(r.normalized_payment_method))
				  AND (rc.min_amount IS NULL OR ISNULL(r.net_amount, r.gross_amount) >= rc.min_amount)
				  AND (rc.max_amount IS NULL OR ISNULL(r.net_amount, r.gross_amount) <= rc.max_amount)
				  AND NOT EXISTS
				  (
					  SELECT 1
					  FROM dbo.customer_loyalty_events e
					  WHERE e.source_type = 'etl_payment_row'
						AND e.source_reference = r.external_row_key
						AND e.rule_id = lr.id
				  )
			)
			INSERT INTO dbo.customer_loyalty_events
			(
				id,
				client_id,
				event_type,
				movement_type,
				source_type,
				source_id,
				source_reference,
				rule_id,
				campaign_id,
				reward_id,
				adjustment_id,
				points_delta,
				monetary_amount,
				payment_method,
				payment_reference,
				occurred_at,
				effective_at,
				expires_at,
				is_expired,
				description,
				created_at,
				created_by_user_id
			)
			SELECT
				NEWID(),
				@ClientId,
				'payment_confirmed',
				'credit',
				'etl_payment_row',
				CONVERT(varchar(100), source_id),
				external_row_key,
				rule_id,
				NULL,
				NULL,
				NULL,
				calculated_points,
				monetary_amount,
				normalized_payment_method,
				CONVERT(varchar(100), source_id),
				occurred_at,
				occurred_at,
				NULL,
				0,
				CONCAT('Pagamento importado pela ETL: ', service_type_raw),
				SYSUTCDATETIME(),
				@CreatedByUserId
			FROM PaymentCandidateEvents
			WHERE calculated_points <> 0;

			SET @CreatedEvents += @@ROWCOUNT;

			;WITH SourceRow AS
			(
				SELECT
					r.*,
					normalized_payment_method =
						CASE LOWER(ISNULL(r.payment_method_raw, ''))
							WHEN 'pix' THEN 'pix'
							WHEN 'dinheiro' THEN 'cash'
							WHEN 'cash' THEN 'cash'
							WHEN 'debito' THEN 'debit_card'
							WHEN 'débito' THEN 'debit_card'
							WHEN 'credito' THEN 'credit_card'
							WHEN 'crédito' THEN 'credit_card'
							WHEN 'boleto' THEN 'boleto'
							WHEN 'transferencia' THEN 'bank_transfer'
							WHEN 'transferência' THEN 'bank_transfer'
							ELSE 'other'
						END
				FROM dbo.etl_import_rows r
				WHERE r.id = @ImportRowId
			),
			PetCandidateEvents AS
			(
				SELECT
					row_id = r.id,
					rule_id = lr.id,
					condition_type = rc.condition_type,
					calculated_points = CAST(
						CASE
							WHEN rc.currency_unit_amount IS NOT NULL
								 AND rc.currency_unit_amount > 0
								 AND rc.points_value IS NOT NULL
								THEN FLOOR(ISNULL(r.net_amount, r.gross_amount) / rc.currency_unit_amount) * rc.points_value

							WHEN rc.multiplier_value IS NOT NULL
								THEN ISNULL(r.net_amount, r.gross_amount) * rc.multiplier_value

							WHEN rc.points_value IS NOT NULL
								THEN rc.points_value

							ELSE 0
						END
					AS int),
					monetary_amount = ISNULL(r.net_amount, r.gross_amount),
					r.normalized_payment_method,
					r.external_row_key,
					r.service_type_raw,
					r.pet_name_raw,
					r.occurred_at
				FROM SourceRow r
				INNER JOIN dbo.loyalty_rules lr
					ON lr.status = 'active'
				   AND lr.category IN ('scoring', 'points')
				INNER JOIN dbo.loyalty_rule_conditions rc
					ON rc.rule_id = lr.id
				WHERE ISNULL(rc.source_type, 'etl_payment_row') = 'etl_payment_row'
				  AND rc.condition_type IN ('service', 'service_type')
				  AND (rc.service_type IS NULL OR rc.service_type = '' OR LOWER(rc.service_type) = LOWER(r.service_type_raw))
				  AND (rc.plan_type IS NULL OR rc.plan_type = '' OR LOWER(rc.plan_type) = LOWER(ISNULL(r.plan_name_raw, '')))
				  AND (rc.package_type IS NULL OR rc.package_type = '' OR LOWER(rc.package_type) = LOWER(ISNULL(r.package_name_raw, '')))
				  AND (rc.payment_method IS NULL OR rc.payment_method = '' OR LOWER(rc.payment_method) = LOWER(r.normalized_payment_method))
				  AND (rc.min_amount IS NULL OR ISNULL(r.net_amount, r.gross_amount) >= rc.min_amount)
				  AND (rc.max_amount IS NULL OR ISNULL(r.net_amount, r.gross_amount) <= rc.max_amount)
				  AND NOT EXISTS
				  (
					  SELECT 1
					  FROM dbo.customer_loyalty_events e
					  WHERE e.source_type = 'etl_payment_row'
						AND e.source_id = CONVERT(varchar(100), r.id)
						AND e.rule_id = lr.id
				  )
			)
			INSERT INTO dbo.customer_loyalty_events
			(
				id,
				client_id,
				event_type,
				movement_type,
				source_type,
				source_id,
				source_reference,
				rule_id,
				campaign_id,
				reward_id,
				adjustment_id,
				points_delta,
				monetary_amount,
				payment_method,
				payment_reference,
				occurred_at,
				effective_at,
				expires_at,
				is_expired,
				description,
				created_at,
				created_by_user_id
			)
			SELECT
				NEWID(),
				@ClientId,
				'payment_confirmed',
				'credit',
				'etl_payment_row',
				CONVERT(varchar(100), row_id),
				external_row_key,
				rule_id,
				NULL,
				NULL,
				NULL,
				calculated_points,
				monetary_amount,
				normalized_payment_method,
				CONVERT(varchar(100), row_id),
				occurred_at,
				occurred_at,
				NULL,
				0,
				CONCAT('Pagamento importado pela ETL: ', service_type_raw, ' - ', pet_name_raw),
				SYSUTCDATETIME(),
				@CreatedByUserId
			FROM PetCandidateEvents
			WHERE calculated_points <> 0;

			SET @CreatedEvents += @@ROWCOUNT;

			SET @TotalCreatedEvents += @CreatedEvents;

            IF @CreatedEvents > 0
            BEGIN
                EXEC dbo.usp_customer_loyalty_balance_rebuild
                    @ClientId = @ClientId;

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
                    CONCAT('Eventos de pontuação criados: ', @CreatedEvents),
                    NULL,
                    SYSUTCDATETIME()
                );
            END
            ELSE
            BEGIN
                SET @IgnoredRows += 1;

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
                    'eligibility_check',
                    'ignored',
                    'Nenhuma regra ativa gerou pontos para esta linha ETL. Verifique points_value, currency_unit_amount ou multiplier_value.',
                    NULL,
                    SYSUTCDATETIME()
                );
            END;

            SET @ProcessedRows += 1;
        END TRY
        BEGIN CATCH
            SET @FailedRows += 1;

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
                'failed',
                ERROR_MESSAGE(),
                NULL,
                SYSUTCDATETIME()
            );
        END CATCH;

        FETCH NEXT FROM cur INTO @ImportRowId;
    END;

    CLOSE cur;
    DEALLOCATE cur;

    SET @FinishedAt = SYSUTCDATETIME();

    SELECT
        run_type = @RunType,
        processed_rows = @ProcessedRows,
        created_events = @TotalCreatedEvents,
        ignored_rows = @IgnoredRows,
        failed_rows = @FailedRows,
        started_at = @StartedAt,
        finished_at = @FinishedAt;
END;
GO

