CREATE   PROCEDURE [dbo].[usp_notification_template_active_get]
    @TemplateKey VARCHAR(120)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        t.id AS template_id,
        t.template_key,
        t.module,
        t.name,
        t.description,
        tv.id AS template_version_id,
        tv.version_number,
        tv.subject_template,
        tv.body_html_template,
        tv.body_text_template,
        tv.created_at,
        tv.activated_at
    FROM dbo.notification_templates t
    INNER JOIN dbo.notification_template_versions tv
        ON tv.template_id = t.id
       AND tv.status = 'active'
    WHERE t.template_key = @TemplateKey
      AND t.is_active = 1
    ORDER BY tv.version_number DESC;
END
GO

