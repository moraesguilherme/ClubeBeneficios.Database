CREATE PROCEDURE [dbo].[usp_etl_import_row_match_upsert]
    @ImportRowId bigint,
    @ClientId uniqueidentifier = NULL,
    @UserId uniqueidentifier = NULL,
    @ClientPetId uniqueidentifier = NULL,
    @PartnerId uniqueidentifier = NULL,
    @MatchStatus varchar(30),
    @MatchConfidence decimal(5,2) = NULL,
    @MatchedByRule varchar(100) = NULL,
    @ReviewRequired bit = 0,
    @ReviewedAt datetime2(7) = NULL,
    @ReviewedByUserId uniqueidentifier = NULL,
    @ReviewNotes varchar(1500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.etl_import_row_matches WHERE import_row_id = @ImportRowId)
    BEGIN
        UPDATE dbo.etl_import_row_matches
        SET
            client_id = @ClientId,
            user_id = @UserId,
            client_pet_id = @ClientPetId,
            partner_id = @PartnerId,
            match_status = @MatchStatus,
            match_confidence = @MatchConfidence,
            matched_by_rule = @MatchedByRule,
            review_required = @ReviewRequired,
            reviewed_at = @ReviewedAt,
            reviewed_by_user_id = @ReviewedByUserId,
            review_notes = @ReviewNotes
        WHERE import_row_id = @ImportRowId;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.etl_import_row_matches
        (
            import_row_id,
            client_id,
            user_id,
            client_pet_id,
            partner_id,
            match_status,
            match_confidence,
            matched_by_rule,
            review_required,
            reviewed_at,
            reviewed_by_user_id,
            review_notes
        )
        VALUES
        (
            @ImportRowId,
            @ClientId,
            @UserId,
            @ClientPetId,
            @PartnerId,
            @MatchStatus,
            @MatchConfidence,
            @MatchedByRule,
            @ReviewRequired,
            @ReviewedAt,
            @ReviewedByUserId,
            @ReviewNotes
        );
    END

    UPDATE dbo.etl_import_rows
    SET
        status = CASE
            WHEN @MatchStatus IN ('matched', 'manually_resolved') AND ISNULL(@ReviewRequired, 0) = 0 THEN 'matched'
            WHEN @MatchStatus IN ('partially_matched', 'not_matched') OR ISNULL(@ReviewRequired, 0) = 1 THEN 'parsed'
            WHEN @MatchStatus = 'discarded' THEN 'ignored'
            ELSE status
        END,
        parsed_at = ISNULL(parsed_at, SYSUTCDATETIME())
    WHERE id = @ImportRowId;

    SELECT *
    FROM dbo.etl_import_row_matches
    WHERE import_row_id = @ImportRowId;
END

GO


