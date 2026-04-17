CREATE PROCEDURE [dbo].[usp_etl_import_row_supersede]
    @ExistingImportRowId bigint,
    @ReplacedByImportRowId bigint = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.etl_import_rows
    SET
        is_current = 0,
        superseded_at = SYSUTCDATETIME(),
        replaced_by_import_row_id = @ReplacedByImportRowId
    WHERE id = @ExistingImportRowId
      AND is_current = 1;

    SELECT *
    FROM dbo.etl_import_rows
    WHERE id = @ExistingImportRowId;
END
GO


