CREATE   PROCEDURE [dbo].[usp_loyalty_score_rebuild_by_client]
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
        @ScoreValue int = 0,
        @LevelCode varchar(30),
        @TrendCode varchar(30) = 'stable',
        @TrendReason varchar(1000) = NULL,
        @UpgradeDistance int = NULL,
        @DowngradeRiskFlag bit = 0,
        @LowRedemptionFlag bit = 0,
        @PreviousLevelCode varchar(30) = NULL,
        @PreviousAverageTicketAmount decimal(18,2) = NULL,
        @NextLevelMinTicket decimal(18,2) = NULL,
        @WindowMonths int = 12,
        @SnapshotId uniqueidentifier = NEWID();

    SELECT
        @AvailablePoints = ISNULL(b.available_points, 0),
        @PendingPoints = ISNULL(b.pending_points, 0)
    FROM dbo.customer_loyalty_balances b
    WHERE b.client_id = @ClientId;

    SELECT TOP 1
        @WindowMonths = evaluation_window_months
    FROM dbo.loyalty_level_thresholds
    WHERE status = 'active'
    ORDER BY display_order ASC;

    IF @WindowMonths IS NULL OR @WindowMonths < 1
        SET @WindowMonths = 12;

    SELECT
        @PointsLast12m = ISNULL(SUM(CASE WHEN e.points_delta > 0 THEN e.points_delta ELSE 0 END), 0),
        @AverageTicketAmount = ISNULL(AVG(CAST(NULLIF(e.monetary_amount, 0) AS decimal(18,2))), 0)
    FROM dbo.customer_loyalty_events e
    WHERE e.client_id = @ClientId
      AND e.occurred_at >= DATEADD(MONTH, -@WindowMonths, SYSUTCDATETIME());

    SELECT
        @RedemptionsLast12m = COUNT(1)
    FROM dbo.loyalty_redemptions r
    WHERE r.client_id = @ClientId
      AND r.status IN ('approved', 'used', 'completed')
      AND r.requested_at >= DATEADD(MONTH, -@WindowMonths, SYSUTCDATETIME());

    SELECT TOP 1
        @PreviousLevelCode = s.level_code,
        @PreviousAverageTicketAmount = s.average_ticket_amount
    FROM dbo.loyalty_score_snapshots s
    WHERE s.client_id = @ClientId
    ORDER BY s.calculated_at DESC, s.created_at DESC;

    SELECT TOP 1
        @LevelCode = level_code
    FROM dbo.loyalty_level_thresholds
    WHERE status = 'active'
      AND @AverageTicketAmount >= min_average_ticket_amount
      AND (
            max_average_ticket_amount IS NULL
            OR @AverageTicketAmount <= max_average_ticket_amount
          )
    ORDER BY display_order DESC;

    IF @LevelCode IS NULL
    BEGIN
        SELECT TOP 1
            @LevelCode = level_code
        FROM dbo.loyalty_level_thresholds
        WHERE status = 'active'
        ORDER BY display_order ASC;
    END

    SELECT TOP 1
        @NextLevelMinTicket = min_average_ticket_amount
    FROM dbo.loyalty_level_thresholds
    WHERE status = 'active'
      AND min_average_ticket_amount > @AverageTicketAmount
    ORDER BY min_average_ticket_amount ASC;

    SET @UpgradeDistance =
        CASE
            WHEN @NextLevelMinTicket IS NULL THEN 0
            ELSE CEILING(@NextLevelMinTicket - @AverageTicketAmount)
        END;

    SET @DowngradeRiskFlag =
        CASE
            WHEN @PreviousAverageTicketAmount IS NOT NULL
             AND @PreviousAverageTicketAmount > @AverageTicketAmount
             AND (@PreviousAverageTicketAmount - @AverageTicketAmount) >= 100
            THEN 1
            ELSE 0
        END;

    SET @LowRedemptionFlag =
        CASE
            WHEN @AvailablePoints >= 5000 AND @RedemptionsLast12m = 0 THEN 1
            ELSE 0
        END;

    SET @TrendCode =
        CASE
            WHEN @DowngradeRiskFlag = 1 THEN 'downgrade'
            WHEN @UpgradeDistance IS NOT NULL AND @UpgradeDistance > 0 AND @UpgradeDistance <= 100 THEN 'upgrade'
            ELSE 'stable'
        END;

    SET @TrendReason =
        CASE
            WHEN @DowngradeRiskFlag = 1 THEN 'Queda relevante no ticket medio em relacao ao ultimo calculo.'
            WHEN @UpgradeDistance IS NOT NULL AND @UpgradeDistance > 0 AND @UpgradeDistance <= 100 THEN 'Cliente proximo da proxima faixa por ticket medio.'
            WHEN @LowRedemptionFlag = 1 THEN 'Saldo alto com baixa utilizacao do programa.'
            ELSE 'Sem sinais criticos no momento.'
        END;

    /* Score operacional continua existindo apenas como indicador,
       mas o nível NÃO é mais definido pelo score. */
    SET @ScoreValue =
        ISNULL(@AvailablePoints / 10, 0) +
        ISNULL(@PointsLast12m / 20, 0) +
        ISNULL(CAST(@AverageTicketAmount / 10 AS int), 0) +
        CASE
            WHEN @RedemptionsLast12m >= 6 THEN 100
            WHEN @RedemptionsLast12m >= 3 THEN 50
            WHEN @RedemptionsLast12m >= 1 THEN 20
            ELSE 0
        END;

    EXEC dbo.usp_loyalty_score_snapshot_create
        @SnapshotId = @SnapshotId,
        @ClientId = @ClientId,
        @ScoreValue = @ScoreValue,
        @LevelCode = @LevelCode,
        @TrendCode = @TrendCode,
        @TrendReason = @TrendReason,
        @AverageTicketAmount = @AverageTicketAmount,
        @AvailablePoints = @AvailablePoints,
        @PendingPoints = @PendingPoints,
        @UpgradeDistance = @UpgradeDistance,
        @DowngradeRiskFlag = @DowngradeRiskFlag,
        @LowRedemptionFlag = @LowRedemptionFlag;

    SELECT *
    FROM dbo.loyalty_score_snapshots
    WHERE id = @SnapshotId;
END;
GO

