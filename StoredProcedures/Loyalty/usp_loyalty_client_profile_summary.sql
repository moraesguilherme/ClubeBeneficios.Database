CREATE   PROCEDURE [dbo].[usp_loyalty_client_profile_summary]
    @ClientId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH LatestScore AS
    (
        SELECT TOP 1
            s.client_id,
            s.score_value,
            s.level_code,
            s.trend_code,
            s.trend_reason,
            s.average_ticket_amount,
            s.available_points,
            s.pending_points,
            s.upgrade_distance,
            s.downgrade_risk_flag,
            s.low_redemption_flag,
            s.calculated_at
        FROM dbo.loyalty_score_snapshots s
        WHERE s.client_id = @ClientId
        ORDER BY s.calculated_at DESC, s.created_at DESC
    ),
    LatestLevel AS
    (
        SELECT TOP 1
            h.client_id,
            h.to_level_code,
            h.changed_at
        FROM dbo.loyalty_level_history h
        WHERE h.client_id = @ClientId
        ORDER BY h.changed_at DESC, h.created_at DESC
    )
    SELECT
        c.id AS client_id,
        c.full_name AS client_name,
        b.available_points,
        b.pending_points,
        b.expired_points,
        b.lifetime_earned_points,
        ls.score_value,
        ls.level_code AS score_level_code,
        ll.to_level_code AS current_level_code,
        ls.trend_code,
        ls.trend_reason,
        ls.average_ticket_amount,
        ls.upgrade_distance,
        ls.downgrade_risk_flag,
        ls.low_redemption_flag,
        ls.calculated_at AS score_calculated_at,
        ll.changed_at AS level_changed_at
    FROM dbo.clients c
    LEFT JOIN dbo.customer_loyalty_balances b
        ON b.client_id = c.id
    LEFT JOIN LatestScore ls
        ON ls.client_id = c.id
    LEFT JOIN LatestLevel ll
        ON ll.client_id = c.id
    WHERE c.id = @ClientId;
END
GO


