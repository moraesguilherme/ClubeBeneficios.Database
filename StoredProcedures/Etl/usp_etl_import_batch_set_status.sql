CREATE PROCEDURE [dbo].[usp_etl_import_batch_set_status]
    @BatchId uniqueidentifier,
    @Status varchar(30),
    @FinishedAt datetime2(7) = NULL,
    @Notes varchar(1500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.etl_import_batches
    SET
        status = @Status,
        finished_at = CASE
            WHEN @FinishedAt IS NOT NULL THEN @FinishedAt
            WHEN @Status IN ('processed', 'processed_with_errors', 'failed', 'cancelled') THEN SYSUTCDATETIME()
            ELSE finished_at
        END,
        notes = COALESCE(@Notes, notes)
    WHERE id = @BatchId;

    SELECT *
    FROM dbo.etl_import_batches
    WHERE id = @BatchId;
END

GO


