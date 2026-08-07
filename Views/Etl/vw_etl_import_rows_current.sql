CREATE VIEW [dbo].[vw_etl_import_rows_current]
AS
SELECT
    r.*
FROM dbo.etl_import_rows r
WHERE r.is_current = 1;
GO