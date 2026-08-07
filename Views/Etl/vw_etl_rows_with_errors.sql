CREATE VIEW [dbo].[vw_etl_rows_with_errors]
AS
SELECT
    r.id AS import_row_id,
    r.batch_id,
    r.row_number,
    r.external_row_key,
    r.status AS row_status,
    e.id AS error_id,
    e.error_code,
    e.error_message,
    e.error_stage,
    e.created_at AS error_created_at
FROM dbo.etl_import_rows r
INNER JOIN dbo.etl_import_row_errors e
    ON e.import_row_id = r.id;

GO
