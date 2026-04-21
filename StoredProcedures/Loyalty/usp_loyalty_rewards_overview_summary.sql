CREATE   PROCEDURE [dbo].[usp_loyalty_rewards_overview_summary]
    @DateFrom datetime2(7) = NULL,
    @DateTo datetime2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartDate datetime2(7) = ISNULL(@DateFrom, DATEADD(DAY, -30, SYSUTCDATETIME()));
    DECLARE @EndDate datetime2(7) = ISNULL(@DateTo, SYSUTCDATETIME());

    SELECT
        active_rewards =
        (
            SELECT COUNT(1)
            FROM dbo.loyalty_rewards r
            WHERE r.status = 'active'
        ),
        redemptions_in_period =
        (
            SELECT COUNT(1)
            FROM dbo.loyalty_redemptions rr
            WHERE rr.requested_at >= @StartDate
              AND rr.requested_at < @EndDate
        ),
        points_consumed_in_period =
        (
            SELECT ABS(ISNULL(SUM(CASE WHEN e.event_type = 'reward_redemption' THEN e.points_delta ELSE 0 END), 0))
            FROM dbo.customer_loyalty_events e
            WHERE e.occurred_at >= @StartDate
              AND e.occurred_at < @EndDate
        ),
        operational_rules_count =
        (
            SELECT COUNT(1)
            FROM dbo.loyalty_rewards r
            WHERE r.minimum_notice_hours IS NOT NULL
               OR r.cumulative_mode IS NOT NULL
               OR r.usage_window_type IS NOT NULL
               OR r.availability_type IS NOT NULL
               OR r.season_type IS NOT NULL
        );
END
GO


