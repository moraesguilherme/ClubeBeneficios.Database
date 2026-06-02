CREATE   PROCEDURE [dbo].[usp_loyalty_reclassify_batch_by_latest_metrics]
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @ClientId uniqueidentifier,
        @LatestLevelCode varchar(30),
        @CurrentLevelCode varchar(30),
        @HistoryId uniqueidentifier,
        @ProcessedClients int = 0;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT DISTINCT s.client_id
        FROM dbo.customer_loyalty_metric_snapshots s;

    OPEN cur;
    FETCH NEXT FROM cur INTO @ClientId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SET @LatestLevelCode = NULL;
            SET @CurrentLevelCode = NULL;

            SELECT TOP 1
                @LatestLevelCode = s.level_code
            FROM dbo.customer_loyalty_metric_snapshots s
            WHERE s.client_id = @ClientId
            ORDER BY s.calculated_at DESC, s.created_at DESC;

            IF @LatestLevelCode IS NOT NULL
            BEGIN
                SELECT TOP 1
                    @CurrentLevelCode = h.to_level_code
                FROM dbo.loyalty_level_history h
                WHERE h.client_id = @ClientId
                ORDER BY h.changed_at DESC, h.created_at DESC;

                IF @CurrentLevelCode IS NULL OR @CurrentLevelCode <> @LatestLevelCode
                BEGIN
                    SET @HistoryId = NEWID();

                    EXEC dbo.usp_loyalty_level_history_add
                        @HistoryId = @HistoryId,
                        @ClientId = @ClientId,
                        @FromLevelCode = @CurrentLevelCode,
                        @ToLevelCode = @LatestLevelCode,
                        @ChangeReason = 'Classificação automática com base em ticket médio.',
                        @SourceType = 'metrics_reclassification',
                        @SourceId = NULL,
                        @CreatedByUserId = @CreatedByUserId;
                END;

                SET @ProcessedClients += 1;
            END;
        END TRY
        BEGIN CATCH
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
                'level_reclassification',
                'failed',
                ERROR_MESSAGE(),
                NULL,
                SYSUTCDATETIME()
            );
        END CATCH;

        FETCH NEXT FROM cur INTO @ClientId;
    END;

    CLOSE cur;
    DEALLOCATE cur;

    SELECT @ProcessedClients AS processed_clients;
END;
GO

