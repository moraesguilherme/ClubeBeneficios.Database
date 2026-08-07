CREATE   PROCEDURE [dbo].[usp_loyalty_event_create_from_source]
    @EventId uniqueidentifier,
    @ClientId uniqueidentifier,
    @EventType varchar(50),
    @MovementType varchar(30),
    @SourceType varchar(50),
    @SourceId varchar(100),
    @SourceReference varchar(150) = NULL,
    @PointsDelta int,
    @RuleId uniqueidentifier = NULL,
    @CampaignId uniqueidentifier = NULL,
    @RewardId uniqueidentifier = NULL,
    @AdjustmentId uniqueidentifier = NULL,
    @MonetaryAmount decimal(18,2) = NULL,
    @PaymentMethod varchar(50) = NULL,
    @PaymentReference varchar(150) = NULL,
    @Description varchar(1500) = NULL,
    @OccurredAt datetime2(7) = NULL,
    @EffectiveAt datetime2(7) = NULL,
    @ExpiresAt datetime2(7) = NULL,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @PointsDelta IS NULL OR @PointsDelta = 0
    BEGIN
        RAISERROR('PointsDelta deve ser diferente de zero.', 16, 1);
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.customer_loyalty_events
        WHERE client_id = @ClientId
          AND source_type = @SourceType
          AND source_id = @SourceId
          AND ISNULL(source_reference, '') = ISNULL(@SourceReference, '')
          AND (
                @RuleId IS NULL
                OR rule_id = @RuleId
              )
    )
    BEGIN
        RAISERROR('Ja existe evento de fidelidade para esta origem/regra/referencia.', 16, 1);
        RETURN;
    END;

    INSERT INTO dbo.customer_loyalty_events
    (
        id,
        client_id,
        event_type,
        movement_type,
        source_type,
        source_id,
        source_reference,
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
    VALUES
    (
        @EventId,
        @ClientId,
        @EventType,
        @MovementType,
        @SourceType,
        @SourceId,
        @SourceReference,
        @RuleId,
        @CampaignId,
        @RewardId,
        @AdjustmentId,
        @PointsDelta,
        @MonetaryAmount,
        @PaymentMethod,
        @PaymentReference,
        ISNULL(@OccurredAt, SYSUTCDATETIME()),
        ISNULL(@EffectiveAt, ISNULL(@OccurredAt, SYSUTCDATETIME())),
        @ExpiresAt,
        0,
        @Description,
        SYSUTCDATETIME(),
        @CreatedByUserId
    );

    EXEC dbo.usp_customer_loyalty_balance_rebuild
        @ClientId = @ClientId;

    SELECT *
    FROM dbo.customer_loyalty_events
    WHERE id = @EventId;
END;
GO

