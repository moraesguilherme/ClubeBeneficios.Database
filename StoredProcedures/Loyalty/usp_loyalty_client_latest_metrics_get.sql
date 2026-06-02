CREATE   PROCEDURE [dbo].[usp_loyalty_client_latest_metrics_get]
    @ClientId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        s.id,
        s.client_id,
        s.level_code,
        s.trend_code,
        s.trend_reason,
        s.average_ticket_amount,
        ISNULL(b.available_points, s.available_points) AS available_points,
		ISNULL(b.pending_points, s.pending_points) AS pending_points,
        s.upgrade_distance_amount,
        s.downgrade_risk_flag,
        s.low_redemption_flag,
        s.calculated_at,
        s.created_at
    FROM dbo.customer_loyalty_metric_snapshots s
	LEFT JOIN dbo.customer_loyalty_balances b
		ON b.client_id = s.client_id
    WHERE s.client_id = @ClientId
    ORDER BY s.calculated_at DESC, s.created_at DESC;
END
GO

