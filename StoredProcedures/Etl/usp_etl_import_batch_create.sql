CREATE PROCEDURE [dbo].[usp_etl_import_batch_create]
    @Id uniqueidentifier,
    @SourceName varchar(100),
    @SourceType varchar(50),
    @FileName varchar(255) = NULL,
    @FileHash varchar(128) = NULL,
    @StartedAt datetime2(7),
    @CreatedByUserId uniqueidentifier = NULL,
    @Notes varchar(1500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.etl_import_batches
    (
        id,
        source_name,
        source_type,
        file_name,
        file_hash,
        status,
        total_rows,
        processed_rows,
        success_rows,
        error_rows,
        started_at,
        finished_at,
        created_by_user_id,
        notes
    )
    VALUES
    (
        @Id,
        @SourceName,
        @SourceType,
        @FileName,
        @FileHash,
        'pending',
        0,
        0,
        0,
        0,
        @StartedAt,
        NULL,
        @CreatedByUserId,
        @Notes
    );

    SELECT *
    FROM dbo.etl_import_batches
    WHERE id = @Id;
END

GO


