CREATE   PROCEDURE [dbo].[usp_benefits_filter_options]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 'statuses' AS bucket, 'active' AS value, 'Ativo' AS label, 1 AS sort_order
    UNION ALL SELECT 'statuses', 'approved', 'Aprovado', 2
    UNION ALL SELECT 'statuses', 'pending_review', 'Pendente de análise', 3
    UNION ALL SELECT 'statuses', 'under_review', 'Em análise', 4
    UNION ALL SELECT 'statuses', 'draft', 'Rascunho', 5
    UNION ALL SELECT 'statuses', 'inactive', 'Inativo', 6
    UNION ALL SELECT 'statuses', 'rejected', 'Reprovado', 7
    UNION ALL SELECT 'statuses', 'expired', 'Expirado', 8
    UNION ALL SELECT 'statuses', 'archived', 'Arquivado', 9

    UNION ALL SELECT 'benefit_types', 'discount', 'Desconto', 1
    UNION ALL SELECT 'benefit_types', 'service', 'Serviço', 2
    UNION ALL SELECT 'benefit_types', 'gift', 'Brinde', 3
    UNION ALL SELECT 'benefit_types', 'daily_rate', 'Diária', 4
    UNION ALL SELECT 'benefit_types', 'evaluation', 'Avaliação', 5
    UNION ALL SELECT 'benefit_types', 'upgrade', 'Upgrade', 6
    UNION ALL SELECT 'benefit_types', 'raffle', 'Sorteio', 7
    UNION ALL SELECT 'benefit_types', 'event', 'Evento', 8
    UNION ALL SELECT 'benefit_types', 'experience', 'Experiência', 9
    UNION ALL SELECT 'benefit_types', 'custom', 'Personalizado', 10

    UNION ALL SELECT 'directions', 'partner_to_matilha', 'Parceiro para cliente Matilha', 1
    UNION ALL SELECT 'directions', 'matilha_to_partner', 'Matilha para cliente do parceiro', 2

    UNION ALL SELECT 'target_actor_types', 'client', 'Cliente Matilha', 1
    UNION ALL SELECT 'target_actor_types', 'partner_customer', 'Cliente do parceiro', 2

    UNION ALL SELECT 'eligibility_types', 'open', 'Aberto', 1
    UNION ALL SELECT 'eligibility_types', 'level', 'Por nível', 2
    UNION ALL SELECT 'eligibility_types', 'behavior', 'Por comportamento', 3
    UNION ALL SELECT 'eligibility_types', 'code', 'Por código', 4
    UNION ALL SELECT 'eligibility_types', 'hybrid', 'Híbrido', 5

    UNION ALL SELECT 'recurrence_types', 'once_per_customer', 'Uma vez por cliente', 1
    UNION ALL SELECT 'recurrence_types', 'first_use_only', 'Somente primeiro uso', 2
    UNION ALL SELECT 'recurrence_types', 'limited_per_period', 'Limitado por período', 3
    UNION ALL SELECT 'recurrence_types', 'unlimited_within_rule', 'Ilimitado dentro da regra', 4

    UNION ALL SELECT 'recurrence_periods', 'day', 'Dia', 1
    UNION ALL SELECT 'recurrence_periods', 'week', 'Semana', 2
    UNION ALL SELECT 'recurrence_periods', 'month', 'Mês', 3
    UNION ALL SELECT 'recurrence_periods', 'quarter', 'Trimestre', 4
    UNION ALL SELECT 'recurrence_periods', 'semester', 'Semestre', 5
    UNION ALL SELECT 'recurrence_periods', 'year', 'Ano', 6

    UNION ALL SELECT 'validity_types', 'continuous', 'Contínuo', 1
    UNION ALL SELECT 'validity_types', 'date_range', 'Período definido', 2
    UNION ALL SELECT 'validity_types', 'until_stock', 'Enquanto houver disponibilidade', 3
    UNION ALL SELECT 'validity_types', 'campaign_period', 'Período de campanha', 4

    UNION ALL SELECT 'stacking_rules', 'non_cumulative', 'Não cumulativo', 1
    UNION ALL SELECT 'stacking_rules', 'allow_with_campaign', 'Permite campanha', 2
    UNION ALL SELECT 'stacking_rules', 'allow_with_fidelity', 'Permite fidelidade', 3

    ORDER BY bucket, sort_order, label;
END
GO

