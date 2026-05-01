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
        @ProcessedRows int = 0,
        @CreatedEvents int = 0,
        @IgnoredRows int = 0,
        @FailedRows int = 0;

    CREATE TABLE #RowsToProcess
    (
        import_row_id bigint NOT NULL PRIMARY KEY
    );

    INSERT INTO #RowsToProcess (import_row_id)
    SELECT TOP (@BatchSize)
        r.id
    FROM dbo.etl_import_rows r
    INNER JOIN dbo.etl_import_row_matches m
        ON m.import_row_id = r.id
    WHERE r.status IN ('matched', 'processed')
      AND m.client_id IS NOT NULL
      AND EXISTS
      (
          SELECT 1
          FROM dbo.loyalty_rules lr
          INNER JOIN dbo.loyalty_rule_conditions rc
              ON rc.rule_id = lr.id
          WHERE lr.status = 'active'
            AND lr.category IN ('scoring', 'points')
            AND ISNULL(rc.source_type, 'etl_payment_row') = 'etl_payment_row'
      )
    ORDER BY r.id ASC;

    DECLARE row_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT import_row_id
        FROM #RowsToProcess
        ORDER BY import_row_id ASC;

    OPEN row_cursor;
    FETCH NEXT FROM row_cursor INTO @ImportRowId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            CREATE TABLE #Result
            (
                import_row_id bigint,
                client_id uniqueidentifier NULL,
                created_events int,
                ignored_rules int,
                failed_rules int
            );

            INSERT INTO #Result
            EXEC dbo.usp_loyalty_process_etl_row
                @ImportRowId = @ImportRowId,
                @CreatedByUserId = @CreatedByUserId;

            SELECT
                @CreatedEvents += ISNULL(SUM(created_events), 0),
                @FailedRows += CASE WHEN ISNULL(SUM(failed_rules), 0) > 0 THEN 1 ELSE 0 END,
                @IgnoredRows += CASE WHEN ISNULL(SUM(created_events), 0) = 0 AND ISNULL(SUM(failed_rules), 0) = 0 THEN 1 ELSE 0 END
            FROM #Result;

            DROP TABLE #Result;

            SET @ProcessedRows += 1;
        END TRY
        BEGIN CATCH
            SET @FailedRows += 1;

            IF OBJECT_ID('tempdb..#Result') IS NOT NULL
                DROP TABLE #Result;

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
                'finalization',
                'failed',
                ERROR_MESSAGE(),
                NULL,
                SYSUTCDATETIME()
            );
        END CATCH;

        FETCH NEXT FROM row_cursor INTO @ImportRowId;
    END;

    CLOSE row_cursor;
    DEALLOCATE row_cursor;

    DROP TABLE #RowsToProcess;

    SET @FinishedAt = SYSUTCDATETIME();

    SELECT
        run_type = @RunType,
        processed_rows = @ProcessedRows,
        created_events = @CreatedEvents,
        ignored_rows = @IgnoredRows,
        failed_rows = @FailedRows,
        started_at = @StartedAt,
        finished_at = @FinishedAt;
END;
GO

