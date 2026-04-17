CREATE PROCEDURE [dbo].[usp_etl_import_row_resolve_state]
    @ExternalRowKey varchar(200),
    @SourceContentHash varchar(64)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExistingId bigint = NULL;
    DECLARE @ExistingHash varchar(64) = NULL;

    SELECT TOP (1)
        @ExistingId = id,
        @ExistingHash = source_content_hash
    FROM dbo.etl_import_rows
    WHERE external_row_key = @ExternalRowKey
      AND is_current = 1
    ORDER BY id DESC;

    IF @ExistingId IS NULL
    BEGIN
        SELECT
            CAST('new' AS varchar(20)) AS row_state,
            CAST(NULL AS bigint) AS existing_import_row_id;
        RETURN;
    END

    IF ISNULL(@ExistingHash, '') = ISNULL(@SourceContentHash, '')
    BEGIN
        SELECT
            CAST('unchanged' AS varchar(20)) AS row_state,
            @ExistingId AS existing_import_row_id;
        RETURN;
    END

    SELECT
        CAST('changed' AS varchar(20)) AS row_state,
        @ExistingId AS existing_import_row_id;
END
GO


