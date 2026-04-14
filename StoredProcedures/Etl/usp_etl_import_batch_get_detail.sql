CREATE PROCEDURE [dbo].[usp_etl_import_batch_get_detail]
    @BatchId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.etl_import_batches
    WHERE id = @BatchId;

    SELECT *
    FROM dbo.vw_etl_batch_row_summary
    WHERE batch_id = @BatchId;

    SELECT *
    FROM dbo.etl_import_rows
    WHERE batch_id = @BatchId
    ORDER BY row_number ASC;
END

GO


