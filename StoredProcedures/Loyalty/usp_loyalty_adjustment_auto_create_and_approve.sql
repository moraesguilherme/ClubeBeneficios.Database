CREATE   PROCEDURE [dbo].[usp_loyalty_adjustment_auto_create_and_approve]
    @ClientId uniqueidentifier,
    @PointsDelta int,
    @Reason varchar(1000),
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @AdjustmentId uniqueidentifier = NEWID(),
        @EventId uniqueidentifier = NEWID();

    INSERT INTO dbo.loyalty_adjustments
    (
        id,
        client_id,
        adjustment_type,
        impact_type,
        points_delta,
        reason,
        requested_by_type,
        status,
        requested_at,
        decided_at,
        created_at,
        updated_at,
        decided_by_user_id
    )
    VALUES
    (
        @AdjustmentId,
        @ClientId,
        'manual_adjustment',
        'points',
        @PointsDelta,
        @Reason,
        'system',
        'approved',
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        @CreatedByUserId
    );

    INSERT INTO dbo.customer_loyalty_events
    (
        id,
        client_id,
        event_type,
        movement_type,
        source_type,
        source_id,
        adjustment_id,
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
        'manual_adjustment',
        CASE WHEN @PointsDelta > 0 THEN 'credit' ELSE 'debit' END,
        'loyalty_adjustment',
        CONVERT(varchar(100), @AdjustmentId),
        @AdjustmentId,
        @PointsDelta,
        @Reason,
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        @CreatedByUserId
    );

    EXEC dbo.usp_customer_loyalty_balance_rebuild
        @ClientId = @ClientId;

    SELECT
        adjustment_id = @AdjustmentId,
        event_id = @EventId,
        status = 'created_and_approved';
END
GO


