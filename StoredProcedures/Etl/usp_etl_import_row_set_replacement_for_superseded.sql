CREATE PROCEDURE [dbo].[usp_etl_import_row_set_replacement_for_superseded]
    @ExternalRowKey varchar(300),
    @ReplacedByImportRowId bigint
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.etl_import_rows
    SET replaced_by_import_row_id = @ReplacedByImportRowId
    WHERE external_row_key = @ExternalRowKey
      AND is_current = 0
      AND superseded_at IS NOT NULL
      AND replaced_by_import_row_id IS NULL;

    SELECT @@ROWCOUNT AS affected_rows;
END
GO