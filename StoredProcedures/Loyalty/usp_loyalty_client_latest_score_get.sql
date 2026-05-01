CREATE   PROCEDURE [dbo].[usp_loyalty_client_latest_score_get]
    @ClientId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        s.id,
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
        s.calculated_at,
        s.created_at
    FROM dbo.loyalty_score_snapshots s
    WHERE s.client_id = @ClientId
    ORDER BY s.calculated_at DESC, s.created_at DESC;
END
GO

