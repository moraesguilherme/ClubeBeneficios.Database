CREATE PROCEDURE [dbo].[usp_etl_import_row_error_add]
    @ImportRowId bigint,
    @ErrorCode varchar(100),
    @ErrorMessage varchar(2000),
    @ErrorStage varchar(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.etl_import_row_errors
    (
        import_row_id,
        error_code,
        error_message,
        error_stage,
        created_at
    )
    VALUES
    (
        @ImportRowId,
        @ErrorCode,
        @ErrorMessage,
        @ErrorStage,
        SYSUTCDATETIME()
    );

    UPDATE dbo.etl_import_rows
    SET
        status = 'error',
        processed_at = ISNULL(processed_at, SYSUTCDATETIME())
    WHERE id = @ImportRowId;

    DECLARE @BatchId uniqueidentifier;

    SELECT @BatchId = batch_id
    FROM dbo.etl_import_rows
    WHERE id = @ImportRowId;

    UPDATE b
    SET
        processed_rows = s.processed_rows,
        success_rows = s.success_rows,
        error_rows = s.error_rows,
        status = CASE
            WHEN s.total_rows > 0 AND s.processed_rows = s.total_rows THEN 'processed_with_errors'
            ELSE 'processing'
        END,
        finished_at = CASE
            WHEN s.total_rows > 0 AND s.processed_rows = s.total_rows THEN SYSUTCDATETIME()
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
    FROM dbo.etl_import_row_errors
    WHERE id = SCOPE_IDENTITY();
END

GO


