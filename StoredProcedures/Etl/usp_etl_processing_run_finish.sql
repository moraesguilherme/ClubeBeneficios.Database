CREATE PROCEDURE [dbo].[usp_etl_processing_run_finish]
    @Id uniqueidentifier,
    @Status varchar(30),
    @ProcessedItems int,
    @SuccessItems int,
    @ErrorItems int,
    @LogSummary varchar(2000) = NULL,
    @FinishedAt datetime2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.etl_processing_runs
    SET
        status = @Status,
        processed_items = @ProcessedItems,
        success_items = @SuccessItems,
        error_items = @ErrorItems,
        log_summary = @LogSummary,
        finished_at = ISNULL(@FinishedAt, SYSUTCDATETIME())
    WHERE id = @Id;

    SELECT *
    FROM dbo.etl_processing_runs
    WHERE id = @Id;
END

GO


