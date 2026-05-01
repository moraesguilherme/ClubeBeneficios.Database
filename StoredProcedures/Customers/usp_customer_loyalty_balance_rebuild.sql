CREATE PROCEDURE [dbo].[usp_customer_loyalty_balance_rebuild]
    @ClientId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @AvailablePoints int,
        @PendingPoints int,
        @ExpiredPoints int,
        @RedeemedPoints int,
        @LifetimeEarnedPoints int,
        @LastMovementAt datetime2(7);

    SELECT
        @AvailablePoints =
            ISNULL(SUM(
                CASE
                    WHEN e.movement_type = 'credit' AND ISNULL(e.is_expired, 0) = 0 THEN e.points_delta
                    WHEN e.movement_type IN ('debit', 'expiration', 'reversal', 'redemption_commit') THEN e.points_delta
                    WHEN e.movement_type = 'adjustment' THEN e.points_delta
                    WHEN e.movement_type = 'redemption_cancel' THEN e.points_delta
                    WHEN e.movement_type = 'redemption_reserve' THEN e.points_delta
                    ELSE 0
                END
            ), 0),
        @PendingPoints =
            ISNULL(SUM(
                CASE
                    WHEN e.movement_type = 'redemption_reserve' THEN ABS(e.points_delta)
                    ELSE 0
                END
            ), 0),
        @ExpiredPoints =
            ISNULL(SUM(
                CASE
                    WHEN e.movement_type = 'expiration' OR ISNULL(e.is_expired, 0) = 1 THEN ABS(e.points_delta)
                    ELSE 0
                END
            ), 0),
        @RedeemedPoints =
            ISNULL(SUM(
                CASE
                    WHEN e.movement_type = 'redemption_commit' THEN ABS(e.points_delta)
                    ELSE 0
                END
            ), 0),
        @LifetimeEarnedPoints =
            ISNULL(SUM(
                CASE
                    WHEN e.points_delta > 0 AND e.movement_type IN ('credit', 'adjustment', 'redemption_cancel') THEN e.points_delta
                    ELSE 0
                END
            ), 0),
        @LastMovementAt = MAX(e.effective_at)
    FROM dbo.customer_loyalty_events e
    WHERE e.client_id = @ClientId;

    IF EXISTS (SELECT 1 FROM dbo.customer_loyalty_balances WHERE client_id = @ClientId)
    BEGIN
        UPDATE dbo.customer_loyalty_balances
        SET
            available_points = ISNULL(@AvailablePoints, 0),
            pending_points = ISNULL(@PendingPoints, 0),
            expired_points = ISNULL(@ExpiredPoints, 0),
            redeemed_points = ISNULL(@RedeemedPoints, 0),
            lifetime_earned_points = ISNULL(@LifetimeEarnedPoints, 0),
            last_movement_at = @LastMovementAt,
            updated_at = SYSUTCDATETIME()
        WHERE client_id = @ClientId;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.customer_loyalty_balances
        (
            client_id,
            available_points,
            pending_points,
            expired_points,
            redeemed_points,
            lifetime_earned_points,
            last_movement_at,
            updated_at
        )
        VALUES
        (
            @ClientId,
            ISNULL(@AvailablePoints, 0),
            ISNULL(@PendingPoints, 0),
            ISNULL(@ExpiredPoints, 0),
            ISNULL(@RedeemedPoints, 0),
            ISNULL(@LifetimeEarnedPoints, 0),
            @LastMovementAt,
            SYSUTCDATETIME()
        );
    END

    SELECT *
    FROM dbo.customer_loyalty_balances
    WHERE client_id = @ClientId;
END

GO