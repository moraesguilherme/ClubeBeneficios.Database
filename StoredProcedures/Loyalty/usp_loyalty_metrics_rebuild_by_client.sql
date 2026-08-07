CREATE   PROCEDURE [dbo].[usp_loyalty_metrics_rebuild_by_client]
    @ClientId uniqueidentifier,
	@ReturnResult bit = 1
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
        @SnapshotId uniqueidentifier = NEWID(),
		@CurrentHistoryLevelCode varchar(30),
		@CalculatedLevelOrder int,
		@CurrentHistoryLevelOrder int;

    -- saldo
    SELECT
        @AvailablePoints = ISNULL(available_points, 0),
        @PendingPoints = ISNULL(pending_points, 0)
    FROM dbo.customer_loyalty_balances
    WHERE client_id = @ClientId;

    -- média financeira (janela móvel últimos 6 meses)
	DECLARE @LastPaymentDate datetime2(7);

	SELECT
		@LastPaymentDate = MAX(e.effective_at)
	FROM dbo.customer_loyalty_events e
	WHERE e.client_id = @ClientId
	  AND e.source_type = 'etl_payment_row'
	  AND e.movement_type = 'credit'
	  AND e.event_type = 'payment_confirmed'
	  AND e.monetary_amount IS NOT NULL
	  AND e.monetary_amount > 0;

	;WITH Payments AS
	(
		SELECT
			source_reference,
			MAX(monetary_amount) AS monetary_amount
		FROM dbo.customer_loyalty_events
		WHERE client_id = @ClientId
		  AND source_type = 'etl_payment_row'
		  AND movement_type = 'credit'
		  AND event_type = 'payment_confirmed'
		  AND monetary_amount IS NOT NULL
		  AND monetary_amount > 0
		  AND (
				@LastPaymentDate IS NULL
				OR effective_at >= DATEADD(MONTH, -6, @LastPaymentDate)
			  )
		GROUP BY source_reference
	)
	SELECT
		@AverageTicketAmount =
			ISNULL(AVG(CAST(monetary_amount AS decimal(18,2))), 0)
	FROM Payments;

	-- resgates últimos 12 meses
	SELECT
		@RedemptionsLast12m = COUNT(1)
	FROM dbo.customer_loyalty_events
	WHERE client_id = @ClientId
	  AND movement_type = 'redemption_commit'
	  AND effective_at >= DATEADD(MONTH, -12, SYSUTCDATETIME());

    -- nível por ticket médio
    SELECT TOP 1
        @LevelCode = level_code
    FROM dbo.loyalty_level_thresholds
    WHERE status = 'active'
      AND @AverageTicketAmount >= min_average_ticket_amount
      AND (max_average_ticket_amount IS NULL OR @AverageTicketAmount <= max_average_ticket_amount)
    ORDER BY display_order DESC;

	IF @LevelCode IS NULL
	BEGIN
		SELECT TOP 1
			@LevelCode = level_code
		FROM dbo.loyalty_level_thresholds
		WHERE status = 'active'
		ORDER BY display_order ASC;
	END

	IF @LevelCode IS NULL
		SET @LevelCode = 'bronze';

	SELECT TOP 1
    @CurrentHistoryLevelCode = h.to_level_code
	FROM dbo.loyalty_level_history h
	WHERE h.client_id = @ClientId
	ORDER BY h.changed_at DESC, h.created_at DESC;

	SELECT
		@CalculatedLevelOrder = t.display_order
	FROM dbo.loyalty_level_thresholds t
	WHERE t.level_code = @LevelCode;

	SELECT
		@CurrentHistoryLevelOrder = t.display_order
	FROM dbo.loyalty_level_thresholds t
	WHERE t.level_code = @CurrentHistoryLevelCode;

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

		IF @CurrentHistoryLevelOrder IS NOT NULL
		   AND @CalculatedLevelOrder IS NOT NULL
		   AND @CalculatedLevelOrder < @CurrentHistoryLevelOrder
		BEGIN
			SET @DowngradeRiskFlag = 1;
		END

    -- flags
    IF @AvailablePoints >= 5000 AND @RedemptionsLast12m = 0
        SET @LowRedemptionFlag = 1;

	SET @TrendCode =
		CASE
			WHEN @DowngradeRiskFlag = 1 THEN 'downgrade'
			WHEN @UpgradeDistance <= 200 THEN 'upgrade'
			ELSE 'stable'
		END;

		SET @TrendReason =
			CASE
				WHEN @DowngradeRiskFlag = 1
					THEN 'Cliente com risco de downgrade.'

				WHEN @UpgradeDistance <= 200
					THEN 'Cliente próximo de upgrade.'

				WHEN @LowRedemptionFlag = 1
					THEN 'Cliente acumulando pontos sem utilização.'

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

    IF @ReturnResult = 1
	BEGIN
		SELECT *
		FROM dbo.customer_loyalty_metric_snapshots
		WHERE id = @SnapshotId;
	END
END
GO

