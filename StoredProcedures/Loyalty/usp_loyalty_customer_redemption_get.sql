CREATE PROCEDURE [dbo].[usp_loyalty_customer_redemption_get]
    @ClientId uniqueidentifier,
    @RedemptionId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        r.id,
        r.client_id,
        r.reward_id,

        rw.title AS reward_title,
        rw.description AS reward_description,

        r.redemption_code,
        r.requested_points_cost,
        r.approved_points_cost,

        r.status,

        status_label =
            CASE r.status
                WHEN 'requested' THEN N'Solicitado'
                WHEN 'under_review' THEN N'Em análise'
                WHEN 'approved' THEN N'Aprovado'
                WHEN 'rejected' THEN N'Rejeitado'
                WHEN 'canceled' THEN N'Cancelado'
                WHEN 'used' THEN N'Utilizado'
                WHEN 'completed' THEN N'Concluído'
                WHEN 'expired' THEN N'Expirado'
                ELSE N'Situação não informada'
            END,

        status_description =
            CASE r.status
                WHEN 'requested'
                    THEN N'Sua solicitação foi registrada e aguarda análise.'
                WHEN 'under_review'
                    THEN N'Sua solicitação está sendo analisada.'
                WHEN 'approved'
                    THEN N'Sua recompensa foi aprovada. Consulte as condições de utilização.'
                WHEN 'rejected'
                    THEN N'Sua solicitação não foi aprovada.'
                WHEN 'canceled'
                    THEN N'Esta solicitação foi cancelada.'
                WHEN 'used'
                    THEN N'A utilização desta recompensa foi registrada.'
                WHEN 'completed'
                    THEN N'Esta solicitação foi concluída.'
                WHEN 'expired'
                    THEN N'O prazo desta solicitação expirou.'
                ELSE N'Consulte as informações desta solicitação.'
            END,

        r.request_channel,

        r.requested_at,
        r.approved_at,
        r.rejected_at,
        r.canceled_at,
        r.used_at,
        r.completed_at,
        r.expires_at,
        r.scheduled_for,

        r.notes,

        rw.availability_summary,
        rw.operational_rule_summary,
        rw.eligible_level_code,
        rw.redemption_mode,
        rw.minimum_notice_hours,
        rw.cumulative_mode,
        rw.usage_window_type,
        rw.usage_window_value,
        rw.availability_type,
        rw.season_type,
        rw.is_transferable,

        r.created_at,
        r.updated_at

    FROM dbo.loyalty_redemptions r
    INNER JOIN dbo.loyalty_rewards rw
        ON rw.id = r.reward_id

    WHERE r.id = @RedemptionId
      AND r.client_id = @ClientId;
END
GO