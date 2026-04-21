CREATE PROCEDURE [dbo].[usp_etl_import_row_supersede_current]
    @ExternalRowKey varchar(300),
    @ReplacedByImportRowId bigint = NULL,
    @SupersededAt datetime2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.etl_import_rows
    SET
        is_current = 0,
        superseded_at = ISNULL(@SupersededAt, SYSUTCDATETIME()),
        replaced_by_import_row_id = @ReplacedByImportRowId
    WHERE external_row_key = @ExternalRowKey
      AND is_current = 1;

    SELECT @@ROWCOUNT AS affected_rows;
END
GO