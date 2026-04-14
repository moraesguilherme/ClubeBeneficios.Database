CREATE PROCEDURE [dbo].[usp_etl_import_row_set_status]
    @ImportRowId bigint,
    @Status varchar(30),
    @ParsedAt datetime2(7) = NULL,
    @ProcessedAt datetime2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BatchId uniqueidentifier;
    DECLARE @PreviousStatus varchar(30);

    SELECT
        @BatchId = batch_id,
        @PreviousStatus = status
    FROM dbo.etl_import_rows
    WHERE id = @ImportRowId;

    UPDATE dbo.etl_import_rows
    SET
        status = @Status,
        parsed_at = CASE WHEN @ParsedAt IS NOT NULL THEN @ParsedAt
                         WHEN @Status IN ('parsed', 'matched') AND parsed_at IS NULL THEN SYSUTCDATETIME()
                         ELSE parsed_at END,
        processed_at = CASE WHEN @ProcessedAt IS NOT NULL THEN @ProcessedAt
                            WHEN @Status IN ('processed', 'ignored', 'error') THEN SYSUTCDATETIME()
                            ELSE processed_at END
    WHERE id = @ImportRowId;

    UPDATE b
    SET
        processed_rows = s.processed_rows,
        success_rows = s.success_rows,
        error_rows = s.error_rows,
        status = CASE
            WHEN b.status IN ('cancelled', 'failed') THEN b.status
            WHEN s.total_rows = 0 THEN b.status
            WHEN s.error_rows > 0 AND s.processed_rows = s.total_rows THEN 'processed_with_errors'
            WHEN s.processed_rows = s.total_rows THEN 'processed'
            WHEN s.processed_rows > 0 THEN 'processing'
            ELSE b.status
        END,
        finished_at = CASE
            WHEN s.total_rows > 0 AND s.processed_rows = s.total_rows THEN ISNULL(b.finished_at, SYSUTCDATETIME())
            ELSE b.finished_at
        END
    FROM dbo.etl_import_batches b
    CROSS APPLY
    (
        SELECT
            COUNT(*) AS total_rows,
            SUM(CASE WHEN r.status IN ('processed', 'ignored', 'error') THEN 1 ELSE 0 END) AS processed_rows,
            SUM(CASE WHEN r.status = 'processed' THEN 1 ELSE 0 END) AS success_rows,
            SUM(CASE WHEN r.status = 'error' THEN 1 ELSE 0 END) AS error_rows
        FROM dbo.etl_import_rows r
        WHERE r.batch_id = b.id
    ) s
    WHERE b.id = @BatchId;

    SELECT *
    FROM dbo.etl_import_rows
    WHERE id = @ImportRowId;
END

GO


