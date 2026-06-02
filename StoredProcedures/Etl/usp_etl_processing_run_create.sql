CREATE PROCEDURE [dbo].[usp_etl_processing_run_create]
    @Id uniqueidentifier,
    @BatchId uniqueidentifier = NULL,
    @RunType varchar(50),
    @StartedAt datetime2(7)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.etl_processing_runs
    (
        id,
        batch_id,
        run_type,
        status,
        started_at,
        finished_at,
        processed_items,
        success_items,
        error_items,
        log_summary
    )
    VALUES
    (
        @Id,
        @BatchId,
        @RunType,
        'processing',
        @StartedAt,
        NULL,
        0,
        0,
        0,
        NULL
    );

    SELECT *
    FROM dbo.etl_processing_runs
    WHERE id = @Id;
END
GO

