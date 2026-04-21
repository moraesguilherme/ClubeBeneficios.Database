CREATE   PROCEDURE [dbo].[usp_loyalty_admin_dashboard_summary]
    @DateFrom datetime2(7) = NULL,
    @DateTo datetime2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartDate datetime2(7) = ISNULL(@DateFrom, DATEADD(DAY, -30, SYSUTCDATETIME()));
    DECLARE @EndDate datetime2(7) = ISNULL(@DateTo, SYSUTCDATETIME());

    ;WITH LatestScore AS
    (
        SELECT
            s.client_id,
            s.score_value,
            s.level_code,
            s.trend_code,
            s.upgrade_distance,
            s.downgrade_risk_flag,
            ROW_NUMBER() OVER (PARTITION BY s.client_id ORDER BY s.calculated_at DESC, s.created_at DESC) AS rn
        FROM dbo.loyalty_score_snapshots s
    )
    SELECT
        clients_in_program =
        (
            SELECT COUNT(DISTINCT b.client_id)
            FROM dbo.customer_loyalty_balances b
        ),
        points_issued =
        (
            SELECT ISNULL(SUM(CASE WHEN e.points_delta > 0 THEN e.points_delta ELSE 0 END), 0)
            FROM dbo.customer_loyalty_events e
            WHERE e.occurred_at >= @StartDate
              AND e.occurred_at < @EndDate
        ),
        points_redeemed =
        (
            SELECT ABS(ISNULL(SUM(CASE WHEN e.event_type = 'reward_redemption' THEN e.points_delta ELSE 0 END), 0))
            FROM dbo.customer_loyalty_events e
            WHERE e.occurred_at >= @StartDate
              AND e.occurred_at < @EndDate
        ),
        points_expiring =
        (
            SELECT ISNULL(SUM(CASE
                WHEN e.points_delta > 0
                 AND e.expires_at IS NOT NULL
                 AND e.is_expired = 0
                 AND e.expires_at >= SYSUTCDATETIME()
                 AND e.expires_at < DATEADD(DAY, 30, SYSUTCDATETIME())
                THEN e.points_delta
                ELSE 0
            END), 0)
            FROM dbo.customer_loyalty_events e
        ),
        upcoming_upgrades =
        (
            SELECT COUNT(1)
            FROM LatestScore s
            WHERE s.rn = 1
              AND s.trend_code = 'upgrade'
        ),
        downgrade_risk =
        (
            SELECT COUNT(1)
            FROM LatestScore s
            WHERE s.rn = 1
              AND s.downgrade_risk_flag = 1
        );
END
GO


