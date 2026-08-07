CREATE   PROCEDURE [dbo].[usp_notification_template_upsert]
    @TemplateKey VARCHAR(120),
    @Module VARCHAR(80),
    @Name VARCHAR(180),
    @Description VARCHAR(1000) = NULL,
    @SubjectTemplate VARCHAR(300),
    @BodyHtmlTemplate VARCHAR(MAX),
    @BodyTextTemplate VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();
    DECLARE @TemplateId UNIQUEIDENTIFIER;
    DECLARE @NextVersionNumber INT;

    BEGIN TRANSACTION;

    SELECT
        @TemplateId = id
    FROM dbo.notification_templates
    WHERE template_key = @TemplateKey;

    IF @TemplateId IS NULL
    BEGIN
        SET @TemplateId = NEWID();

        INSERT INTO dbo.notification_templates
        (
            id,
            template_key,
            module,
            name,
            description,
            is_active,
            created_at,
            updated_at
        )
        VALUES
        (
            @TemplateId,
            @TemplateKey,
            @Module,
            @Name,
            @Description,
            1,
            @Now,
            @Now
        );

        SET @NextVersionNumber = 1;
    END
    ELSE
    BEGIN
        UPDATE dbo.notification_templates
        SET
            module = @Module,
            name = @Name,
            description = @Description,
            is_active = 1,
            updated_at = @Now
        WHERE id = @TemplateId;

        SELECT
            @NextVersionNumber = ISNULL(MAX(version_number), 0) + 1
        FROM dbo.notification_template_versions
        WHERE template_id = @TemplateId;

        UPDATE dbo.notification_template_versions
        SET
            status = 'archived'
        WHERE template_id = @TemplateId
          AND status = 'active';
    END

    INSERT INTO dbo.notification_template_versions
    (
        template_id,
        version_number,
        status,
        subject_template,
        body_html_template,
        body_text_template,
        created_at,
        activated_at
    )
    VALUES
    (
        @TemplateId,
        @NextVersionNumber,
        'active',
        @SubjectTemplate,
        @BodyHtmlTemplate,
        @BodyTextTemplate,
        @Now,
        @Now
    );

    COMMIT TRANSACTION;

    SELECT
        @TemplateId AS template_id,
        @TemplateKey AS template_key,
        @NextVersionNumber AS version_number;
END
GO

