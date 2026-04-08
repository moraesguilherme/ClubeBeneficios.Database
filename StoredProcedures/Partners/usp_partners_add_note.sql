CREATE PROCEDURE dbo.usp_partners_add_note
    @PartnerId         UNIQUEIDENTIFIER,
    @NoteType          VARCHAR(30) = 'general',
    @Content           VARCHAR(MAX),
    @CreatedByUserId   UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.partner_notes
    (
        partner_id,
        note_type,
        content,
        created_by_user_id,
        created_at
    )
    VALUES
    (
        @PartnerId,
        ISNULL(NULLIF(LTRIM(RTRIM(@NoteType)), ''), 'general'),
        @Content,
        @CreatedByUserId,
        SYSUTCDATETIME()
    );
END
GO