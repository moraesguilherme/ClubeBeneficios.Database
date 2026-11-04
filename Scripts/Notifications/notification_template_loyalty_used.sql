
USE [ClubeBeneficiosDb];
GO

------------------------------------------------------------
-- RECOMPENSA UTILIZADA
------------------------------------------------------------
EXEC dbo.usp_notification_template_upsert
    @TemplateKey = 'loyalty.redemption.used.client',
    @Module = 'loyalty',
    @Name = 'Recompensa utilizada - Cliente Matilha',
    @Description = 'Confirma ao cliente que a utilizacao da recompensa foi registrada.',
    @SubjectTemplate = 'Utilizacao registrada: {{rewardTitle}}',
    @BodyHtmlTemplate = '
<div style="font-family:Arial,sans-serif;color:#153a35;line-height:1.6;">
  <h2 style="color:#0d5c55;">Recompensa utilizada!</h2>

  <p>Ola, {{customerName}}!</p>

  <p>A utilizacao da sua recompensa de fidelidade foi registrada pela equipe Matilha Feliz.</p>

  <div style="background:#f7fbf8;border:1px solid #dce9e4;border-radius:14px;padding:16px;margin:20px 0;">
    <p><strong>Recompensa:</strong> {{rewardTitle}}</p>
    <p><strong>Status:</strong> {{statusLabel}}</p>
    <p><strong>Utilizada em:</strong> {{usedAt}}</p>
    <p><strong>Pontos do resgate:</strong> {{approvedPointsCost}}</p>
  </div>

  <p>Obrigado por participar do nosso programa de fidelidade!</p>

  <p>Voce pode acompanhar seus resgates em Minha Fidelidade, na area Meus resgates.</p>

  <hr style="border:none;border-top:1px solid #dce9e4;margin:24px 0;" />
  <p style="font-size:13px;color:#5f756f;">Equipe Matilha Feliz</p>
</div>',
    @BodyTextTemplate = '
Ola, {{customerName}}!

A utilizacao da sua recompensa foi registrada.

Recompensa: {{rewardTitle}}
Status: {{statusLabel}}
Utilizada em: {{usedAt}}
Pontos do resgate: {{approvedPointsCost}}

Obrigado por participar do programa de fidelidade!

Equipe Matilha Feliz';
GO

------------------------------------------------------------
-- RECOMPENSA EXPIRADA
------------------------------------------------------------
EXEC dbo.usp_notification_template_upsert
    @TemplateKey = 'loyalty.redemption.expired.client',
    @Module = 'loyalty',
    @Name = 'Recompensa expirada - Cliente Matilha',
    @Description = 'Informa ao cliente que o prazo para utilizacao da recompensa terminou.',
    @SubjectTemplate = 'Prazo encerrado: {{rewardTitle}}',
    @BodyHtmlTemplate = '
<div style="font-family:Arial,sans-serif;color:#153a35;line-height:1.6;">
  <h2 style="color:#0d5c55;">Prazo de utilizacao encerrado</h2>

  <p>Ola, {{customerName}}!</p>

  <p>O prazo para utilizar sua recompensa
  <strong>{{rewardTitle}}</strong> chegou ao fim.</p>

  <div style="background:#f7fbf8;border:1px solid #dce9e4;border-radius:14px;padding:16px;margin:20px 0;">
    <p><strong>Recompensa:</strong> {{rewardTitle}}</p>
    <p><strong>Status:</strong> {{statusLabel}}</p>
    <p><strong>Validade:</strong> {{expiresAt}}</p>
  </div>

  <p>Esta solicitacao foi encerrada por vencimento do prazo de utilizacao.</p>

  <p>Para consultar seu historico, acesse Minha Fidelidade, em Meus resgates.</p>

  <p>Se precisar de esclarecimentos, entre em contato com nossa equipe.</p>

  <hr style="border:none;border-top:1px solid #dce9e4;margin:24px 0;" />
  <p style="font-size:13px;color:#5f756f;">Equipe Matilha Feliz</p>
</div>',
    @BodyTextTemplate = '
Ola, {{customerName}}!

O prazo para utilizar sua recompensa chegou ao fim.

Recompensa: {{rewardTitle}}
Status: {{statusLabel}}
Validade: {{expiresAt}}

Esta solicitacao foi encerrada por vencimento do prazo.

Acompanhe seus resgates em Minha Fidelidade > Meus resgates.

Em caso de duvidas, entre em contato com nossa equipe.

Equipe Matilha Feliz';
GO
