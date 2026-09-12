SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @CreatedByUserId UNIQUEIDENTIFIER = NULL;

DECLARE
    @TemplateId UNIQUEIDENTIFIER,
    @TemplateKey VARCHAR(120),
    @Module VARCHAR(80),
    @Name VARCHAR(180),
    @Description VARCHAR(500),
    @SubjectTemplate NVARCHAR(500),
    @BodyHtmlTemplate NVARCHAR(MAX),
    @BodyTextTemplate NVARCHAR(MAX),
    @NextVersionNumber INT;

--------------------------------------------------------------------------------
-- TEMPLATE: benefits.benefit.submitted.partner
--------------------------------------------------------------------------------

SET @TemplateId = NULL;
SET @NextVersionNumber = NULL;

SET @TemplateKey = 'benefits.benefit.submitted.partner';
SET @Module = 'benefits';
SET @Name = 'Benefício enviado para análise - parceiro';
SET @Description = 'E-mail enviado ao parceiro quando um benefício é cadastrado e enviado para análise da Matilha.';

SET @SubjectTemplate = N'Benefício enviado para análise: {{benefitTitle}}';

SET @BodyHtmlTemplate = N'
<div style="font-family: Arial, sans-serif; color: #153a35; line-height: 1.6;">
  <h2 style="color: #0d5c55; margin-bottom: 16px;">Benefício enviado para análise</h2>

  <p>Olá, {{partnerName}}!</p>

  <p>
    Recebemos o cadastro do benefício <strong>{{benefitTitle}}</strong>.
  </p>

  <p>
    Ele foi enviado para análise da equipe Matilha Feliz e ficará pendente até
    a validação das informações.
  </p>

  <div style="background: #f7fbf8; border: 1px solid #dce9e4; border-radius: 14px; padding: 16px; margin: 20px 0;">
    <p style="margin: 0 0 8px 0;"><strong>Benefício:</strong> {{benefitTitle}}</p>
    <p style="margin: 0 0 8px 0;"><strong>Status atual:</strong> {{statusLabel}}</p>
    <p style="margin: 0 0 8px 0;"><strong>Direção:</strong> {{directionLabel}}</p>
    <p style="margin: 0;"><strong>Observação:</strong> {{reason}}</p>
  </div>

  <p>
    Assim que houver uma atualização, você receberá uma nova comunicação.
  </p>

  <hr style="border: none; border-top: 1px solid #dce9e4; margin: 24px 0;" />

  <p style="font-size: 13px; color: #5f756f;">
    Equipe Matilha Feliz
  </p>
</div>';

SET @BodyTextTemplate = N'
Olá, {{partnerName}}!

Recebemos o cadastro do benefício {{benefitTitle}}.

Ele foi enviado para análise da equipe Matilha Feliz e ficará pendente até a validação das informações.

Benefício: {{benefitTitle}}
Status atual: {{statusLabel}}
Direção: {{directionLabel}}
Observação: {{reason}}

Assim que houver uma atualização, você receberá uma nova comunicação.

Equipe Matilha Feliz
';

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT @TemplateId = id
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
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END
    ELSE
    BEGIN
        UPDATE dbo.notification_templates
        SET
            module = @Module,
            name = @Name,
            description = @Description,
            is_active = 1,
            updated_at = SYSUTCDATETIME()
        WHERE id = @TemplateId;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.notification_template_versions
        WHERE template_id = @TemplateId
          AND status = 'active'
          AND subject_template = @SubjectTemplate
          AND body_html_template = @BodyHtmlTemplate
          AND body_text_template = @BodyTextTemplate
    )
    BEGIN
        UPDATE dbo.notification_template_versions
        SET status = 'archived'
        WHERE template_id = @TemplateId
          AND status = 'active';

        SELECT @NextVersionNumber = ISNULL(MAX(version_number), 0) + 1
        FROM dbo.notification_template_versions
        WHERE template_id = @TemplateId;

        INSERT INTO dbo.notification_template_versions
        (
            id,
            template_id,
            version_number,
            status,
            subject_template,
            body_html_template,
            body_text_template,
            created_by_user_id,
            created_at,
            activated_at
        )
        VALUES
        (
            NEWID(),
            @TemplateId,
            @NextVersionNumber,
            'active',
            @SubjectTemplate,
            @BodyHtmlTemplate,
            @BodyTextTemplate,
            @CreatedByUserId,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;

--------------------------------------------------------------------------------
-- TEMPLATE: benefits.benefit.submitted.admin
--------------------------------------------------------------------------------

SET @TemplateId = NULL;
SET @NextVersionNumber = NULL;

SET @TemplateKey = 'benefits.benefit.submitted.admin';
SET @Module = 'benefits';
SET @Name = 'Novo benefício aguardando análise - admin';
SET @Description = 'E-mail enviado à Matilha quando um parceiro cadastra um benefício para análise.';

SET @SubjectTemplate = N'Novo benefício aguardando análise: {{benefitTitle}}';

SET @BodyHtmlTemplate = N'
<div style="font-family: Arial, sans-serif; color: #153a35; line-height: 1.6;">
  <h2 style="color: #0d5c55; margin-bottom: 16px;">Novo benefício aguardando análise</h2>

  <p>
    Um novo benefício foi cadastrado no Clube Matilha e está aguardando análise.
  </p>

  <div style="background: #f7fbf8; border: 1px solid #dce9e4; border-radius: 14px; padding: 16px; margin: 20px 0;">
    <p style="margin: 0 0 8px 0;"><strong>Parceiro:</strong> {{partnerName}}</p>
    <p style="margin: 0 0 8px 0;"><strong>Benefício:</strong> {{benefitTitle}}</p>
    <p style="margin: 0 0 8px 0;"><strong>Status atual:</strong> {{statusLabel}}</p>
    <p style="margin: 0 0 8px 0;"><strong>Direção:</strong> {{directionLabel}}</p>
    <p style="margin: 0;"><strong>Observação:</strong> {{reason}}</p>
  </div>

  <p>
    Acesse a central de aprovação para revisar as informações e definir o próximo status.
  </p>

  <hr style="border: none; border-top: 1px solid #dce9e4; margin: 24px 0;" />

  <p style="font-size: 13px; color: #5f756f;">
    Notificação automática do Clube Matilha
  </p>
</div>';

SET @BodyTextTemplate = N'
Novo benefício aguardando análise.

Um novo benefício foi cadastrado no Clube Matilha e está aguardando análise.

Parceiro: {{partnerName}}
Benefício: {{benefitTitle}}
Status atual: {{statusLabel}}
Direção: {{directionLabel}}
Observação: {{reason}}

Acesse a central de aprovação para revisar as informações e definir o próximo status.

Notificação automática do Clube Matilha
';

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT @TemplateId = id
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
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END
    ELSE
    BEGIN
        UPDATE dbo.notification_templates
        SET
            module = @Module,
            name = @Name,
            description = @Description,
            is_active = 1,
            updated_at = SYSUTCDATETIME()
        WHERE id = @TemplateId;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.notification_template_versions
        WHERE template_id = @TemplateId
          AND status = 'active'
          AND subject_template = @SubjectTemplate
          AND body_html_template = @BodyHtmlTemplate
          AND body_text_template = @BodyTextTemplate
    )
    BEGIN
        UPDATE dbo.notification_template_versions
        SET status = 'archived'
        WHERE template_id = @TemplateId
          AND status = 'active';

        SELECT @NextVersionNumber = ISNULL(MAX(version_number), 0) + 1
        FROM dbo.notification_template_versions
        WHERE template_id = @TemplateId;

        INSERT INTO dbo.notification_template_versions
        (
            id,
            template_id,
            version_number,
            status,
            subject_template,
            body_html_template,
            body_text_template,
            created_by_user_id,
            created_at,
            activated_at
        )
        VALUES
        (
            NEWID(),
            @TemplateId,
            @NextVersionNumber,
            'active',
            @SubjectTemplate,
            @BodyHtmlTemplate,
            @BodyTextTemplate,
            @CreatedByUserId,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;

--------------------------------------------------------------------------------
-- TEMPLATE: benefits.benefit.status_changed.partner
--------------------------------------------------------------------------------

SET @TemplateId = NULL;
SET @NextVersionNumber = NULL;

SET @TemplateKey = 'benefits.benefit.status_changed.partner';
SET @Module = 'benefits';
SET @Name = 'Status do benefício alterado - parceiro';
SET @Description = 'E-mail enviado ao parceiro quando o status de um benefício é alterado.';

SET @SubjectTemplate = N'Atualização do benefício: {{benefitTitle}}';

SET @BodyHtmlTemplate = N'
<div style="font-family: Arial, sans-serif; color: #153a35; line-height: 1.6;">
  <h2 style="color: #0d5c55; margin-bottom: 16px;">Status do benefício atualizado</h2>

  <p>Olá, {{partnerName}}!</p>

  <p>
    O benefício <strong>{{benefitTitle}}</strong> teve uma atualização de status.
  </p>

  <div style="background: #f7fbf8; border: 1px solid #dce9e4; border-radius: 14px; padding: 16px; margin: 20px 0;">
    <p style="margin: 0 0 8px 0;"><strong>Benefício:</strong> {{benefitTitle}}</p>
    <p style="margin: 0 0 8px 0;"><strong>Status anterior:</strong> {{previousStatusLabel}}</p>
    <p style="margin: 0 0 8px 0;"><strong>Status atual:</strong> {{statusLabel}}</p>
    <p style="margin: 0 0 8px 0;"><strong>Direção:</strong> {{directionLabel}}</p>
    <p style="margin: 0;"><strong>Observação:</strong> {{reason}}</p>
  </div>

  <p>
    Acesse sua área de parceiro para acompanhar os detalhes do benefício.
  </p>

  <hr style="border: none; border-top: 1px solid #dce9e4; margin: 24px 0;" />

  <p style="font-size: 13px; color: #5f756f;">
    Equipe Matilha Feliz
  </p>
</div>';

SET @BodyTextTemplate = N'
Olá, {{partnerName}}!

O benefício {{benefitTitle}} teve uma atualização de status.

Benefício: {{benefitTitle}}
Status anterior: {{previousStatusLabel}}
Status atual: {{statusLabel}}
Direção: {{directionLabel}}
Observação: {{reason}}

Acesse sua área de parceiro para acompanhar os detalhes do benefício.

Equipe Matilha Feliz
';

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT @TemplateId = id
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
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END
    ELSE
    BEGIN
        UPDATE dbo.notification_templates
        SET
            module = @Module,
            name = @Name,
            description = @Description,
            is_active = 1,
            updated_at = SYSUTCDATETIME()
        WHERE id = @TemplateId;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.notification_template_versions
        WHERE template_id = @TemplateId
          AND status = 'active'
          AND subject_template = @SubjectTemplate
          AND body_html_template = @BodyHtmlTemplate
          AND body_text_template = @BodyTextTemplate
    )
    BEGIN
        UPDATE dbo.notification_template_versions
        SET status = 'archived'
        WHERE template_id = @TemplateId
          AND status = 'active';

        SELECT @NextVersionNumber = ISNULL(MAX(version_number), 0) + 1
        FROM dbo.notification_template_versions
        WHERE template_id = @TemplateId;

        INSERT INTO dbo.notification_template_versions
        (
            id,
            template_id,
            version_number,
            status,
            subject_template,
            body_html_template,
            body_text_template,
            created_by_user_id,
            created_at,
            activated_at
        )
        VALUES
        (
            NEWID(),
            @TemplateId,
            @NextVersionNumber,
            'active',
            @SubjectTemplate,
            @BodyHtmlTemplate,
            @BodyTextTemplate,
            @CreatedByUserId,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;

--------------------------------------------------------------------------------
-- TEMPLATE: benefits.benefit.status_changed.admin
--------------------------------------------------------------------------------

SET @TemplateId = NULL;
SET @NextVersionNumber = NULL;

SET @TemplateKey = 'benefits.benefit.status_changed.admin';
SET @Module = 'benefits';
SET @Name = 'Status do benefício alterado - admin';
SET @Description = 'E-mail enviado à Matilha quando o status de um benefício é alterado.';

SET @SubjectTemplate = N'Status de benefício alterado: {{benefitTitle}}';

SET @BodyHtmlTemplate = N'
<div style="font-family: Arial, sans-serif; color: #153a35; line-height: 1.6;">
  <h2 style="color: #0d5c55; margin-bottom: 16px;">Status de benefício alterado</h2>

  <p>
    Um benefício do Clube Matilha teve alteração de status.
  </p>

  <div style="background: #f7fbf8; border: 1px solid #dce9e4; border-radius: 14px; padding: 16px; margin: 20px 0;">
    <p style="margin: 0 0 8px 0;"><strong>Parceiro:</strong> {{partnerName}}</p>
    <p style="margin: 0 0 8px 0;"><strong>Benefício:</strong> {{benefitTitle}}</p>
    <p style="margin: 0 0 8px 0;"><strong>Status anterior:</strong> {{previousStatusLabel}}</p>
    <p style="margin: 0 0 8px 0;"><strong>Status atual:</strong> {{statusLabel}}</p>
    <p style="margin: 0 0 8px 0;"><strong>Direção:</strong> {{directionLabel}}</p>
    <p style="margin: 0;"><strong>Observação:</strong> {{reason}}</p>
  </div>

  <p>
    Esta mensagem foi gerada automaticamente após a atualização do benefício.
  </p>

  <hr style="border: none; border-top: 1px solid #dce9e4; margin: 24px 0;" />

  <p style="font-size: 13px; color: #5f756f;">
    Notificação automática do Clube Matilha
  </p>
</div>';

SET @BodyTextTemplate = N'
Status de benefício alterado.

Um benefício do Clube Matilha teve alteração de status.

Parceiro: {{partnerName}}
Benefício: {{benefitTitle}}
Status anterior: {{previousStatusLabel}}
Status atual: {{statusLabel}}
Direção: {{directionLabel}}
Observação: {{reason}}

Esta mensagem foi gerada automaticamente após a atualização do benefício.

Notificação automática do Clube Matilha
';

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT @TemplateId = id
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
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END
    ELSE
    BEGIN
        UPDATE dbo.notification_templates
        SET
            module = @Module,
            name = @Name,
            description = @Description,
            is_active = 1,
            updated_at = SYSUTCDATETIME()
        WHERE id = @TemplateId;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.notification_template_versions
        WHERE template_id = @TemplateId
          AND status = 'active'
          AND subject_template = @SubjectTemplate
          AND body_html_template = @BodyHtmlTemplate
          AND body_text_template = @BodyTextTemplate
    )
    BEGIN
        UPDATE dbo.notification_template_versions
        SET status = 'archived'
        WHERE template_id = @TemplateId
          AND status = 'active';

        SELECT @NextVersionNumber = ISNULL(MAX(version_number), 0) + 1
        FROM dbo.notification_template_versions
        WHERE template_id = @TemplateId;

        INSERT INTO dbo.notification_template_versions
        (
            id,
            template_id,
            version_number,
            status,
            subject_template,
            body_html_template,
            body_text_template,
            created_by_user_id,
            created_at,
            activated_at
        )
        VALUES
        (
            NEWID(),
            @TemplateId,
            @NextVersionNumber,
            'active',
            @SubjectTemplate,
            @BodyHtmlTemplate,
            @BodyTextTemplate,
            @CreatedByUserId,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;