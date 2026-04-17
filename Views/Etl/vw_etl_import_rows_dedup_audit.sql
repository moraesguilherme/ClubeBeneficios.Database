CREATE VIEW [dbo].[vw_etl_import_rows_dedup_audit]
AS
SELECT
    r.external_row_key,
    COUNT(*) AS total_versions,
    SUM(CASE WHEN r.is_current = 1 THEN 1 ELSE 0 END) AS current_versions,
    MAX(r.id) AS latest_import_row_id,
    MAX(r.source_content_hash) AS latest_source_content_hash,
    MAX(r.source_file_name) AS latest_source_file_name,
    MAX(r.source_sheet_name) AS latest_source_sheet_name,
    MAX(r.row_number) AS latest_row_number
FROM dbo.etl_import_rows r
GROUP BY r.external_row_key;
GO