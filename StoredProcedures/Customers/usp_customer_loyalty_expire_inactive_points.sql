CREATE PROCEDURE [dbo].[usp_customer_loyalty_expire_inactive_points]
    @AsOf datetime2(7),
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Threshold datetime2(7) = DATEADD(MONTH, -6, @AsOf);

    ;WITH candidates AS
    (
        SELECT
            b.client_id,
            b.available_points,
            b.last_movement_at
        FROM dbo.customer_loyalty_balances b
        WHERE
            b.available_points > 0
            AND b.last_movement_at IS NOT NULL
            AND b.last_movement_at <= @Threshold
    )
    INSERT INTO dbo.customer_loyalty_events
    (
        id,
        client_id,
        event_type,
        movement_type,
        source_type,
        source_id,
        rule_id,
        campaign_id,
        reward_id,
        adjustment_id,
        points_delta,
        monetary_amount,
        payment_method,
        payment_reference,
        occurred_at,
        effective_at,
        expires_at,
        is_expired,
        description,
        created_at,
        created_by_user_id
    )
    SELECT
        NEWID(),
        c.client_id,
        'points_expired',
        'expiration',
        'custom',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        -ABS(c.available_points),
        NULL,
        NULL,
        NULL,
        @AsOf,
        @AsOf,
        @AsOf,
        1,
        'Expiracao automatica por 6 meses sem movimentacao.',
        SYSUTCDATETIME(),
        @CreatedByUserId
    FROM candidates c
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.customer_loyalty_events e
        WHERE
            e.client_id = c.client_id
            AND e.event_type = 'points_expired'
            AND e.effective_at = @AsOf
    );

    UPDATE e
    SET
        is_expired = 1
    FROM dbo.customer_loyalty_events e
    WHERE
        e.client_id IN
        (
            SELECT c.client_id
            FROM dbo.customer_loyalty_balances c
            WHERE
                c.available_points > 0
                AND c.last_movement_at IS NOT NULL
                AND c.last_movement_at <= @Threshold
        )
        AND e.movement_type = 'credit'
        AND e.expires_at IS NOT NULL
        AND e.expires_at <= @AsOf;

    EXEC dbo.usp_customer_loyalty_balance_rebuild_all;
END

GO

