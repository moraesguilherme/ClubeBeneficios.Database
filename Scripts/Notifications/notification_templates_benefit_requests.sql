EXEC dbo.usp_notification_template_upsert
    @TemplateKey = 'benefits.request.submitted.admin',
    @Module = 'benefits',
    @Name = 'Nova solicitação pública de benefício',
    @Description = 'Enviado para a Matilha quando um cliente de parceiro solicita um benefício pela vitrine pública.',
    @SubjectTemplate = 'Nova solicitação de benefício - {{benefitTitle}}',
    @BodyHtmlTemplate = '
        <p>Olá, Matilha.</p>
        <p>Uma nova solicitação pública de benefício foi enviada pela vitrine de um parceiro.</p>

        <p><strong>Parceiro:</strong> {{partnerName}}</p>
        <p><strong>Benefício:</strong> {{benefitTitle}}</p>
        <p><strong>Cliente:</strong> {{requesterName}}</p>
        <p><strong>E-mail:</strong> {{requesterEmail}}</p>
        <p><strong>Pet:</strong> {{petName}}</p>
        <p><strong>Status:</strong> {{requestStatusLabel}}</p>
        <p><strong>Data da solicitação:</strong> {{requestedAt}}</p>
        <p><strong>Protocolo:</strong> {{requestId}}</p>

        <p>Acesse o painel administrativo para analisar a solicitação.</p>
    ',
    @BodyTextTemplate = '
Nova solicitação pública de benefício.

Parceiro: {{partnerName}}
Benefício: {{benefitTitle}}
Cliente: {{requesterName}}
E-mail: {{requesterEmail}}
Pet: {{petName}}
Status: {{requestStatusLabel}}
Data da solicitação: {{requestedAt}}
Protocolo: {{requestId}}

Acesse o painel administrativo para analisar a solicitação.
';
GO

EXEC dbo.usp_notification_template_upsert
    @TemplateKey = 'benefits.request.status_changed.requester',
    @Module = 'benefits',
    @Name = 'Atualização da solicitação de benefício para o solicitante',
    @Description = 'Enviado ao solicitante quando uma solicitação de benefício é aprovada, reprovada ou exige ajustes.',
    @SubjectTemplate = 'Atualização da sua solicitação - {{benefitTitle}}',
    @BodyHtmlTemplate = '
        <p>Olá, {{requesterName}}.</p>

        <p>Sua solicitação de benefício foi atualizada.</p>

        <p><strong>Benefício:</strong> {{benefitTitle}}</p>
        <p><strong>Parceiro:</strong> {{partnerName}}</p>
        <p><strong>Pet:</strong> {{petName}}</p>
        <p><strong>Status:</strong> {{requestStatusLabel}}</p>
        <p><strong>Observação:</strong> {{reviewRecommendation}}</p>

        <p>Em caso de dúvidas, entre em contato com a Matilha.</p>
    ',
    @BodyTextTemplate = '
Olá, {{requesterName}}.

Sua solicitação de benefício foi atualizada.

Benefício: {{benefitTitle}}
Parceiro: {{partnerName}}
Pet: {{petName}}
Status: {{requestStatusLabel}}
Observação: {{reviewRecommendation}}

Em caso de dúvidas, entre em contato com a Matilha.
';
GO

EXEC dbo.usp_notification_template_upsert
    @TemplateKey = 'benefits.request.status_changed.partner',
    @Module = 'benefits',
    @Name = 'Atualização da solicitação de benefício para o parceiro',
    @Description = 'Enviado ao parceiro quando uma solicitação de benefício vinculada à parceria é aprovada, reprovada ou exige ajustes.',
    @SubjectTemplate = 'Atualização de solicitação de benefício - {{benefitTitle}}',
    @BodyHtmlTemplate = '
        <p>Olá, {{partnerName}}.</p>

        <p>Uma solicitação de benefício vinculada à sua parceria foi atualizada.</p>

        <p><strong>Benefício:</strong> {{benefitTitle}}</p>
        <p><strong>Solicitante:</strong> {{requesterName}}</p>
        <p><strong>Pet:</strong> {{petName}}</p>
        <p><strong>Status:</strong> {{requestStatusLabel}}</p>
        <p><strong>Observação:</strong> {{reviewRecommendation}}</p>
    ',
    @BodyTextTemplate = '
Olá, {{partnerName}}.

Uma solicitação de benefício vinculada à sua parceria foi atualizada.

Benefício: {{benefitTitle}}
Solicitante: {{requesterName}}
Pet: {{petName}}
Status: {{requestStatusLabel}}
Observação: {{reviewRecommendation}}
';
GO

EXEC dbo.usp_notification_template_upsert
    @TemplateKey = 'benefits.request.status_changed.admin',
    @Module = 'benefits',
    @Name = 'Atualização da solicitação de benefício para admin',
    @Description = 'Enviado para a Matilha quando uma solicitação de benefício muda de status.',
    @SubjectTemplate = 'Solicitação de benefício atualizada - {{benefitTitle}}',
    @BodyHtmlTemplate = '
        <p>Olá, Matilha.</p>

        <p>Uma solicitação de benefício foi atualizada.</p>

        <p><strong>Parceiro:</strong> {{partnerName}}</p>
        <p><strong>Benefício:</strong> {{benefitTitle}}</p>
        <p><strong>Solicitante:</strong> {{requesterName}}</p>
        <p><strong>Pet:</strong> {{petName}}</p>
        <p><strong>Status:</strong> {{requestStatusLabel}}</p>
        <p><strong>Observação:</strong> {{reviewRecommendation}}</p>
    ',
    @BodyTextTemplate = '
Olá, Matilha.

Uma solicitação de benefício foi atualizada.

Parceiro: {{partnerName}}
Benefício: {{benefitTitle}}
Solicitante: {{requesterName}}
Pet: {{petName}}
Status: {{requestStatusLabel}}
Observação: {{reviewRecommendation}}
';
GO