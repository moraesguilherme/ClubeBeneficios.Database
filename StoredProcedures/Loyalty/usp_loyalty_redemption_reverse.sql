CREATE   PROCEDURE [dbo].[usp_loyalty_redemption_reverse]
    @RedemptionId uniqueidentifier,
    @Reason varchar(1000),
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @ClientId uniqueidentifier,
        @Points int,
        @EventId uniqueidentifier = NEWID();

    SELECT
        @ClientId = client_id,
        @Points = approved_points_cost
    FROM dbo.loyalty_redemptions
    WHERE id = @RedemptionId;

    IF @ClientId IS NULL
    BEGIN
        RAISERROR('Resgate não encontrado.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.customer_loyalty_events
    (
        id,
        client_id,
        event_type,
        movement_type,
        source_type,
        source_id,
        points_delta,
        description,
        occurred_at,
        effective_at,
        created_at,
        created_by_user_id
    )
    VALUES
    (
        @EventId,
        @ClientId,
        'redemption_reversal',
        'credit',
        'redemption',
        CONVERT(varchar(100), @RedemptionId),
        @Points,
        CONCAT('Reversão de resgate: ', @Reason),
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        @CreatedByUserId
    );

    EXEC dbo.usp_customer_loyalty_balance_rebuild
        @ClientId = @ClientId;

    SELECT status = 'reversed', event_id = @EventId;
END
GO

