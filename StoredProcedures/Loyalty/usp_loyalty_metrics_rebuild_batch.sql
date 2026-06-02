CREATE   PROCEDURE [dbo].[usp_loyalty_metrics_rebuild_batch]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @ClientId uniqueidentifier,
        @ProcessedClients int = 0;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT b.client_id
        FROM dbo.customer_loyalty_balances b;

    OPEN cur;
    FETCH NEXT FROM cur INTO @ClientId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            EXEC dbo.usp_loyalty_metrics_rebuild_by_client
                @ClientId = @ClientId,
                @ReturnResult = 0;

            SET @ProcessedClients += 1;
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
                'metrics_rebuild',
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

