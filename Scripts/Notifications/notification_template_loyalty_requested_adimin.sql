EXEC dbo.usp_notification_template_upsert
    @TemplateKey = 'loyalty.redemption.requested.admin',
    @Module = 'loyalty',
    @Name = 'Novo resgate solicitado - Administracao',
    @Description = 'Notifica a Matilha sobre uma nova solicitacao de recompensa.',
    @SubjectTemplate = 'Nova solicitacao de recompensa: {{rewardTitle}}',
    @BodyHtmlTemplate = '
<div style="font-family:Arial,sans-serif;color:#153a35;line-height:1.6;">
  <h2 style="color:#0d5c55;">Nova solicitacao de recompensa</h2>

  <p>Um Cliente Matilha solicitou uma recompensa de fidelidade.</p>

  <div style="background:#f7fbf8;border:1px solid #dce9e4;border-radius:14px;padding:16px;margin:20px 0;">
    <p><strong>Cliente:</strong> {{customerName}}</p>
    <p><strong>Recompensa:</strong> {{rewardTitle}}</p>
    <p><strong>Pontos:</strong> {{pointsCost}}</p>
    <p><strong>Status:</strong> {{statusLabel}}</p>
    <p><strong>Data:</strong> {{requestedAt}}</p>
    <p><strong>ID do resgate:</strong> {{redemptionId}}</p>
  </div>

  <p>Acesse o painel administrativo para analisar a solicitacao.</p>

  <p style="font-size:13px;color:#5f756f;">Clube Matilha</p>
</div>',
    @BodyTextTemplate = '
Nova solicitacao de recompensa.

Cliente: {{customerName}}
Recompensa: {{rewardTitle}}
Pontos: {{pointsCost}}
Status: {{statusLabel}}
Data: {{requestedAt}}
ID do resgate: {{redemptionId}}

Acesse o painel administrativo para analisar.';
GO