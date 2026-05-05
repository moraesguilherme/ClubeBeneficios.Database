CREATE   PROCEDURE [dbo].[usp_loyalty_metrics_rebuild_by_client]
    @ClientId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @AvailablePoints int = 0,
        @PendingPoints int = 0,
        @PointsLast12m int = 0,
        @AverageTicketAmount decimal(18,2) = 0,
        @RedemptionsLast12m int = 0,
        @LevelCode varchar(30),
        @TrendCode varchar(30) = 'stable',
        @TrendReason varchar(1000),
        @UpgradeDistance decimal(18,2),
        @DowngradeRiskFlag bit = 0,
        @LowRedemptionFlag bit = 0,
        @PreviousAverageTicket decimal(18,2),
        @NextLevelMin decimal(18,2),
        @SnapshotId uniqueidentifier = NEWID();

    -- saldo
    SELECT
        @AvailablePoints = ISNULL(available_points, 0),
        @PendingPoints = ISNULL(pending_points, 0)
    FROM dbo.customer_loyalty_balances
    WHERE client_id = @ClientId;

    -- média financeira
    SELECT
        @AverageTicketAmount =
            ISNULL(AVG(CAST(NULLIF(monetary_amount, 0) AS decimal(18,2))), 0)
    FROM dbo.customer_loyalty_events
    WHERE client_id = @ClientId;

    -- nível por ticket médio
    SELECT TOP 1
        @LevelCode = level_code
    FROM dbo.loyalty_level_thresholds
    WHERE status = 'active'
      AND @AverageTicketAmount >= min_average_ticket_amount
      AND (max_average_ticket_amount IS NULL OR @AverageTicketAmount <= max_average_ticket_amount)
    ORDER BY display_order DESC;

    -- próximo nível
    SELECT TOP 1
        @NextLevelMin = min_average_ticket_amount
    FROM dbo.loyalty_level_thresholds
    WHERE min_average_ticket_amount > @AverageTicketAmount
    ORDER BY min_average_ticket_amount ASC;

    SET @UpgradeDistance =
        CASE WHEN @NextLevelMin IS NULL THEN 0
             ELSE @NextLevelMin - @AverageTicketAmount
        END;

    -- flags
    IF @AvailablePoints >= 5000 AND @RedemptionsLast12m = 0
        SET @LowRedemptionFlag = 1;

    SET @TrendCode =
        CASE
            WHEN @UpgradeDistance <= 100 THEN 'upgrade'
            ELSE 'stable'
        END;

    SET @TrendReason =
        CASE
            WHEN @UpgradeDistance <= 100 THEN 'Cliente próximo de upgrade.'
            ELSE 'Sem variação relevante.'
        END;

    INSERT INTO dbo.customer_loyalty_metric_snapshots
    (
        id,
        client_id,
        level_code,
        trend_code,
        trend_reason,
        average_ticket_amount,
        available_points,
        pending_points,
        upgrade_distance_amount,
        downgrade_risk_flag,
        low_redemption_flag,
        calculated_at,
        created_at
    )
    VALUES
    (
        @SnapshotId,
        @ClientId,
        @LevelCode,
        @TrendCode,
        @TrendReason,
        @AverageTicketAmount,
        @AvailablePoints,
        @PendingPoints,
        @UpgradeDistance,
        @DowngradeRiskFlag,
        @LowRedemptionFlag,
        SYSUTCDATETIME(),
        SYSUTCDATETIME()
    );

    SELECT *
    FROM dbo.customer_loyalty_metric_snapshots
    WHERE id = @SnapshotId;
END
GO

