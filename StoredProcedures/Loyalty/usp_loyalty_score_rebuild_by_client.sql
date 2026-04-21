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
        @PreviousScore int = NULL,
        @SnapshotId uniqueidentifier = NEWID();

    SELECT
        @AvailablePoints = ISNULL(b.available_points, 0),
        @PendingPoints = ISNULL(b.pending_points, 0)
    FROM dbo.customer_loyalty_balances b
    WHERE b.client_id = @ClientId;

    SELECT
        @PointsLast12m = ISNULL(SUM(CASE WHEN e.points_delta > 0 THEN e.points_delta ELSE 0 END), 0),
        @AverageTicketAmount = ISNULL(AVG(CAST(ISNULL(e.monetary_amount, 0) AS decimal(18,2))), 0)
    FROM dbo.customer_loyalty_events e
    WHERE e.client_id = @ClientId
      AND e.occurred_at >= DATEADD(MONTH, -12, SYSUTCDATETIME());

    SELECT
        @RedemptionsLast12m = COUNT(1)
    FROM dbo.loyalty_redemptions r
    WHERE r.client_id = @ClientId
      AND r.status IN ('approved', 'used', 'completed')
      AND r.requested_at >= DATEADD(MONTH, -12, SYSUTCDATETIME());

    SELECT TOP 1
        @PreviousScore = s.score_value
    FROM dbo.loyalty_score_snapshots s
    WHERE s.client_id = @ClientId
    ORDER BY s.calculated_at DESC, s.created_at DESC;

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

    SET @LevelCode =
        CASE
            WHEN @ScoreValue >= 1000 THEN 'diamond'
            WHEN @ScoreValue >= 700 THEN 'gold'
            WHEN @ScoreValue >= 400 THEN 'silver'
            ELSE 'bronze'
        END;

    IF @ScoreValue >= 1000
        SET @UpgradeDistance = 0;
    ELSE IF @ScoreValue >= 700
        SET @UpgradeDistance = 1000 - @ScoreValue;
    ELSE IF @ScoreValue >= 400
        SET @UpgradeDistance = 700 - @ScoreValue;
    ELSE
        SET @UpgradeDistance = 400 - @ScoreValue;

    SET @LowRedemptionFlag =
        CASE
            WHEN @AvailablePoints >= 5000 AND @RedemptionsLast12m = 0 THEN 1
            ELSE 0
        END;

    SET @DowngradeRiskFlag =
        CASE
            WHEN @PreviousScore IS NOT NULL AND @PreviousScore > @ScoreValue AND (@PreviousScore - @ScoreValue) >= 100 THEN 1
            ELSE 0
        END;

    SET @TrendCode =
        CASE
            WHEN @DowngradeRiskFlag = 1 THEN 'downgrade'
            WHEN @UpgradeDistance <= 100 THEN 'upgrade'
            ELSE 'stable'
        END;

    SET @TrendReason =
        CASE
            WHEN @DowngradeRiskFlag = 1 THEN 'Queda relevante de score na compara��o com o �ltimo c�lculo.'
            WHEN @UpgradeDistance <= 100 THEN 'Cliente pr�ximo da pr�xima faixa.'
            WHEN @LowRedemptionFlag = 1 THEN 'Saldo alto com baixa utiliza��o do programa.'
            ELSE 'Sem sinais cr�ticos no momento.'
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
END
GO


