EXEC dbo.usp_notification_template_upsert
    @TemplateKey = 'loyalty.redemption.approved.client',
    @Module = 'loyalty',
    @Name = 'Resgate aprovado - Cliente Matilha',
    @Description = 'Informa ao cliente a aprovacao da recompensa e o debito dos pontos.',
    @SubjectTemplate = 'Sua recompensa foi aprovada: {{rewardTitle}}',
    @BodyHtmlTemplate = '
<div style="font-family:Arial,sans-serif;color:#153a35;line-height:1.6;">

  <h2 style="color:#0d5c55;">Sua recompensa foi aprovada!</h2>

  <p>Ola, {{customerName}}!</p>

  <p>Temos uma otima noticia! Sua solicitacao de resgate foi aprovada pela equipe Matilha Feliz.</p>

  <div style="background:#f7fbf8;border:1px solid #dce9e4;border-radius:14px;padding:16px;margin:20px 0;">
    <p><strong>Recompensa:</strong> {{rewardTitle}}</p>
    <p><strong>Pontos debitados:</strong> {{approvedPointsCost}}</p>
    <p><strong>Status:</strong> {{statusLabel}}</p>
  </div>

  <p>Os pontos correspondentes foram debitados do seu saldo de fidelidade.</p>

  <p>Para utilizar sua recompensa, entre em contato com nossa equipe e observe as condicoes de utilizacao.</p>

  <p>Voce pode acompanhar seu resgate em Minha Fidelidade, na area Meus resgates.</p>

  <hr style="border:none;border-top:1px solid #dce9e4;margin:24px 0;" />
  <p style="font-size:13px;color:#5f756f;">Equipe Matilha Feliz</p>

</div>',
    @BodyTextTemplate = '
Ola, {{customerName}}!

Sua recompensa foi aprovada!

Recompensa: {{rewardTitle}}
Pontos debitados: {{approvedPointsCost}}
Status: {{statusLabel}}

Os pontos correspondentes foram debitados do seu saldo de fidelidade.

Para utilizar sua recompensa, entre em contato com nossa equipe e observe as condicoes de utilizacao.

Acompanhe em Minha Fidelidade > Meus resgates.

Equipe Matilha Feliz';
GO
