CREATE VIEW [dbo].[vw_etl_batches_admin_list]
AS
SELECT
    b.id,
    b.source_name,
    b.source_type,
    b.file_name,
    b.file_hash,
    b.status,
    b.total_rows,
    b.processed_rows,
    b.success_rows,
    b.error_rows,
    CASE
        WHEN b.total_rows <= 0 THEN CAST(0 AS decimal(9,2))
        ELSE CAST((b.processed_rows * 100.0) / b.total_rows AS decimal(9,2))
    END AS progress_percent,
    b.started_at,
    b.finished_at,
    b.created_by_user_id,
    b.notes
FROM dbo.etl_import_batches b;

GO