CREATE   PROCEDURE [dbo].[usp_loyalty_score_snapshot_create]
    @SnapshotId uniqueidentifier,
    @ClientId uniqueidentifier,
    @ScoreValue int,
    @LevelCode varchar(30),
    @TrendCode varchar(30),
    @TrendReason varchar(1000) = NULL,
    @AverageTicketAmount decimal(18,2) = NULL,
    @AvailablePoints int,
    @PendingPoints int,
    @UpgradeDistance int = NULL,
    @DowngradeRiskFlag bit,
    @LowRedemptionFlag bit
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.loyalty_score_snapshots
    (
        id,
        client_id,
        score_value,
        level_code,
        trend_code,
        trend_reason,
        average_ticket_amount,
        available_points,
        pending_points,
        upgrade_distance,
        downgrade_risk_flag,
        low_redemption_flag,
        calculated_at,
        created_at
    )
    VALUES
    (
        @SnapshotId,
        @ClientId,
        @ScoreValue,
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
    FROM dbo.loyalty_score_snapshots
    WHERE id = @SnapshotId;
END
GO

