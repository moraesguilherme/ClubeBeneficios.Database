CREATE PROCEDURE [dbo].[usp_etl_rows_get_pending_processing]
    @BatchId uniqueidentifier = NULL,
    @Top int = 500
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@Top)
        *
    FROM dbo.vw_etl_rows_pending_processing
    WHERE @BatchId IS NULL OR batch_id = @BatchId
    ORDER BY batch_id ASC, row_number ASC;
END

GO