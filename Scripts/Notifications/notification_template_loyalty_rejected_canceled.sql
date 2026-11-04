
USE [ClubeBeneficiosDb];
GO

------------------------------------------------------------
-- TEMPLATE: RECOMPENSA REJEITADA
------------------------------------------------------------
EXEC dbo.usp_notification_template_upsert
    @TemplateKey = 'loyalty.redemption.rejected.client',
    @Module = 'loyalty',
    @Name = 'Resgate rejeitado - Cliente Matilha',
    @Description = 'Informa ao cliente que sua solicitacao de recompensa nao foi aprovada.',
    @SubjectTemplate = 'Atualizacao sobre seu resgate: {{rewardTitle}}',
    @BodyHtmlTemplate = '
<div style="font-family:Arial,sans-serif;color:#153a35;line-height:1.6;">
  <h2 style="color:#0d5c55;">Atualizacao da sua solicitacao</h2>

  <p>Ola, {{customerName}}!</p>

  <p>Informamos que sua solicitacao de resgate da recompensa
  <strong>{{rewardTitle}}</strong> nao foi aprovada neste momento.</p>

  <div style="background:#f7fbf8;border:1px solid #dce9e4;border-radius:14px;padding:16px;margin:20px 0;">
    <p><strong>Recompensa:</strong> {{rewardTitle}}</p>
    <p><strong>Pontos solicitados:</strong> {{pointsCost}}</p>
    <p><strong>Status:</strong> {{statusLabel}}</p>
  </div>

  <p>Nenhum ponto foi debitado por esta solicitacao rejeitada.</p>

  <p>Voce pode acompanhar seu historico de resgates na area
  Minha Fidelidade, em Meus resgates.</p>

  <p>Se precisar de esclarecimentos, entre em contato com nossa equipe.</p>

  <hr style="border:none;border-top:1px solid #dce9e4;margin:24px 0;" />
  <p style="font-size:13px;color:#5f756f;">Equipe Matilha Feliz</p>
</div>',
    @BodyTextTemplate = '
Ola, {{customerName}}!

Sua solicitacao de resgate nao foi aprovada neste momento.

Recompensa: {{rewardTitle}}
Pontos solicitados: {{pointsCost}}
Status: {{statusLabel}}

Nenhum ponto foi debitado por esta solicitacao rejeitada.

Acompanhe seu historico em Minha Fidelidade > Meus resgates.

Em caso de duvidas, entre em contato com nossa equipe.

Equipe Matilha Feliz';
GO

------------------------------------------------------------
-- TEMPLATE: RECOMPENSA CANCELADA
------------------------------------------------------------
EXEC dbo.usp_notification_template_upsert
    @TemplateKey = 'loyalty.redemption.canceled.client',
    @Module = 'loyalty',
    @Name = 'Resgate cancelado - Cliente Matilha',
    @Description = 'Informa ao cliente o cancelamento e o tratamento dos pontos.',
    @SubjectTemplate = 'Seu resgate foi cancelado: {{rewardTitle}}',
    @BodyHtmlTemplate = '
<div style="font-family:Arial,sans-serif;color:#153a35;line-height:1.6;">
  <h2 style="color:#0d5c55;">Resgate cancelado</h2>

  <p>Ola, {{customerName}}!</p>

  <p>Informamos que a solicitacao de resgate da recompensa
  <strong>{{rewardTitle}}</strong> foi cancelada.</p>

  <div style="background:#f7fbf8;border:1px solid #dce9e4;border-radius:14px;padding:16px;margin:20px 0;">
    <p><strong>Recompensa:</strong> {{rewardTitle}}</p>
    <p><strong>Pontos:</strong> {{pointsCost}}</p>
    <p><strong>Status:</strong> {{statusLabel}}</p>
  </div>

  <p>{{statusMessage}}</p>

  <p>Voce pode consultar os detalhes em
  Minha Fidelidade, na area Meus resgates.</p>

  <p>Em caso de duvidas, entre em contato com nossa equipe.</p>

  <hr style="border:none;border-top:1px solid #dce9e4;margin:24px 0;" />
  <p style="font-size:13px;color:#5f756f;">Equipe Matilha Feliz</p>
</div>',
    @BodyTextTemplate = '
Ola, {{customerName}}!

Sua solicitacao de resgate foi cancelada.

Recompensa: {{rewardTitle}}
Pontos: {{pointsCost}}
Status: {{statusLabel}}

{{statusMessage}}

Consulte os detalhes em Minha Fidelidade > Meus resgates.

Equipe Matilha Feliz';
GO
