SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @CreatedByUserId UNIQUEIDENTIFIER = NULL;

--------------------------------------------------------------------------------
-- TEMPLATE: partner_account_approved
--------------------------------------------------------------------------------

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

SET @TemplateKey = 'partner_account_approved';
SET @Module = 'partners';
SET @Name = 'Parceiro aprovado - ativação de conta';
SET @Description = 'E-mail enviado ao parceiro quando a solicitação de parceria é aprovada e a conta precisa ser ativada.';

SET @SubjectTemplate = N'Sua parceria com a Matilha Feliz foi aprovada';

SET @BodyHtmlTemplate = N'
<div style="font-family: Arial, sans-serif; color: #153a35; line-height: 1.6;">
  <h2 style="color: #0d5c55; margin-bottom: 16px;">Sua parceria foi aprovada!</h2>

  <p>Olá, {{responsibleName}}!</p>

  <p>
    Temos uma ótima notícia: a solicitação de parceria da empresa
    <strong>{{partnerName}}</strong> foi aprovada pela Matilha Feliz.
  </p>

  <p>
    Para concluir o acesso ao Clube Matilha, você precisa ativar sua conta,
    revisar os dados da parceria e criar sua senha de acesso.
  </p>

  <p style="margin: 24px 0;">
    <a href="{{activationUrl}}"
       style="display: inline-block; background: #0d5c55; color: #ffffff; text-decoration: none; padding: 12px 20px; border-radius: 12px; font-weight: bold;">
      Ativar minha conta
    </a>
  </p>

  <p>
    Este link ficará disponível até <strong>{{expiresAt}}</strong>.
  </p>

  <p>
    Caso o botão acima não funcione, copie e cole o link abaixo no seu navegador:
  </p>

  <p style="word-break: break-all; color: #0d5c55;">
    {{activationUrl}}
  </p>

  <hr style="border: none; border-top: 1px solid #dce9e4; margin: 24px 0;" />

  <p style="font-size: 13px; color: #5f756f;">
    Dados da parceria:<br />
    Empresa: <strong>{{partnerName}}</strong><br />
    Responsável: <strong>{{responsibleName}}</strong><br />
    Cargo/Função: <strong>{{responsibleRole}}</strong><br />
    Telefone: <strong>{{responsiblePhone}}</strong>
  </p>

  <p style="font-size: 13px; color: #5f756f;">
    Equipe Matilha Feliz
  </p>
</div>';

SET @BodyTextTemplate = N'
Olá, {{responsibleName}}!

Temos uma ótima notícia: a solicitação de parceria da empresa {{partnerName}} foi aprovada pela Matilha Feliz.

Para concluir o acesso ao Clube Matilha, acesse o link abaixo, revise os dados da parceria e crie sua senha:

{{activationUrl}}

Este link ficará disponível até {{expiresAt}}.

Dados da parceria:
Empresa: {{partnerName}}
Responsável: {{responsibleName}}
Cargo/Função: {{responsibleRole}}
Telefone: {{responsiblePhone}}

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
        SET status = 'inactive'
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
-- TEMPLATE: partner_account_rejected
--------------------------------------------------------------------------------

SET @TemplateId = NULL;
SET @NextVersionNumber = NULL;

SET @TemplateKey = 'partner_account_rejected';
SET @Module = 'partners';
SET @Name = 'Solicitação de parceria não aprovada';
SET @Description = 'E-mail enviado ao parceiro quando a solicitação de parceria não é aprovada.';

SET @SubjectTemplate = N'Atualização sobre sua solicitação de parceria';

SET @BodyHtmlTemplate = N'
<div style="font-family: Arial, sans-serif; color: #153a35; line-height: 1.6;">
  <h2 style="color: #0d5c55; margin-bottom: 16px;">Atualização sobre sua solicitação</h2>

  <p>Olá, {{responsibleName}}!</p>

  <p>
    Agradecemos o interesse da empresa <strong>{{partnerName}}</strong>
    em fazer parte do Clube Matilha.
  </p>

  <p>
    Após análise das informações enviadas, neste momento não seguiremos com a
    ativação da parceria.
  </p>

  <p>
    Essa decisão considera os critérios atuais de operação, perfil de parceria,
    disponibilidade e aderência ao formato do Clube Matilha.
  </p>

  <p>
    Caso futuramente exista uma nova oportunidade de parceria, poderemos retomar
    o contato ou reavaliar uma nova solicitação.
  </p>

  <hr style="border: none; border-top: 1px solid #dce9e4; margin: 24px 0;" />

  <p style="font-size: 13px; color: #5f756f;">
    Equipe Matilha Feliz
  </p>
</div>';

SET @BodyTextTemplate = N'
Olá, {{responsibleName}}!

Agradecemos o interesse da empresa {{partnerName}} em fazer parte do Clube Matilha.

Após análise das informações enviadas, neste momento não seguiremos com a ativação da parceria.

Essa decisão considera os critérios atuais de operação, perfil de parceria, disponibilidade e aderência ao formato do Clube Matilha.

Caso futuramente exista uma nova oportunidade de parceria, poderemos retomar o contato ou reavaliar uma nova solicitação.

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
        SET status = 'inactive'
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