CREATE PROCEDURE [dbo].[usp_etl_import_row_pet_candidate_upsert]
    @ImportRowId            bigint,
    @PetNameRaw             varchar(200),
    @NormalizedPetName      varchar(200) = NULL,
    @ClientPetId            uniqueidentifier = NULL,
    @MatchConfidence        decimal(5,2) = NULL,
    @ReviewRequired         bit = 0,
    @IsPrimary              bit = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExistingId bigint;

    SELECT TOP (1)
        @ExistingId = id
    FROM dbo.etl_import_row_pet_candidates
    WHERE import_row_id = @ImportRowId
      AND pet_name_raw = @PetNameRaw;

    IF @ExistingId IS NULL
    BEGIN
        INSERT INTO dbo.etl_import_row_pet_candidates
        (
            import_row_id,
            pet_name_raw,
            normalized_pet_name,
            client_pet_id,
            match_confidence,
            review_required,
            is_primary
        )
        VALUES
        (
            @ImportRowId,
            @PetNameRaw,
            @NormalizedPetName,
            @ClientPetId,
            @MatchConfidence,
            @ReviewRequired,
            @IsPrimary
        );

        SELECT CAST(SCOPE_IDENTITY() AS bigint) AS id;
        RETURN;
    END

    UPDATE dbo.etl_import_row_pet_candidates
       SET normalized_pet_name = @NormalizedPetName,
           client_pet_id = @ClientPetId,
           match_confidence = @MatchConfidence,
           review_required = @ReviewRequired,
           is_primary = @IsPrimary
     WHERE id = @ExistingId;

    SELECT @ExistingId AS id;
END
GO


