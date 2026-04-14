CREATE VIEW [dbo].[vw_etl_batch_row_summary]
AS
SELECT
    r.batch_id,
    COUNT_BIG(*) AS total_rows,
    SUM(CASE WHEN r.status = 'pending' THEN 1 ELSE 0 END) AS pending_rows,
    SUM(CASE WHEN r.status = 'parsed' THEN 1 ELSE 0 END) AS parsed_rows,
    SUM(CASE WHEN r.status = 'matched' THEN 1 ELSE 0 END) AS matched_rows,
    SUM(CASE WHEN r.status = 'processed' THEN 1 ELSE 0 END) AS processed_rows,
    SUM(CASE WHEN r.status = 'ignored' THEN 1 ELSE 0 END) AS ignored_rows,
    SUM(CASE WHEN r.status = 'error' THEN 1 ELSE 0 END) AS error_rows,
    SUM(CASE WHEN m.review_required = 1 THEN 1 ELSE 0 END) AS review_required_rows
FROM dbo.etl_import_rows r
LEFT JOIN dbo.etl_import_row_matches m
    ON m.import_row_id = r.id
GROUP BY
    r.batch_id;

GO