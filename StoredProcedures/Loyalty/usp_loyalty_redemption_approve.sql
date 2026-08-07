CREATE   PROCEDURE [dbo].[usp_loyalty_redemption_approve]
    @RedemptionId uniqueidentifier,
    @ApprovedPointsCost int = NULL,
    @DecisionNotes varchar(1500) = NULL,
    @DecidedByUserId uniqueidentifier = NULL,
    @LedgerEventId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ClientId uniqueidentifier;
    DECLARE @RewardId uniqueidentifier;
    DECLARE @CurrentStatus varchar(30);
    DECLARE @RequestedPointsCost int;
    DECLARE @FinalPointsCost int;
    DECLARE @RewardTitle varchar(150);

    SELECT
        @ClientId = r.client_id,
        @RewardId = r.reward_id,
        @CurrentStatus = r.status,
        @RequestedPointsCost = r.requested_points_cost
    FROM dbo.loyalty_redemptions r
    WHERE r.id = @RedemptionId;

    IF @CurrentStatus IS NULL
    BEGIN
        RAISERROR('Resgate nao encontrado.', 16, 1);
        RETURN;
    END

    IF @CurrentStatus NOT IN ('requested', 'under_review')
    BEGIN
        RAISERROR('Somente resgates em requested/under_review podem ser aprovados.', 16, 1);
        RETURN;
    END

    SELECT @RewardTitle = title
    FROM dbo.loyalty_rewards
    WHERE id = @RewardId;

    SET @FinalPointsCost = ISNULL(@ApprovedPointsCost, @RequestedPointsCost);

    IF @FinalPointsCost <= 0
    BEGIN
        RAISERROR('ApprovedPointsCost deve ser maior que zero.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

        UPDATE dbo.loyalty_redemptions
        SET
            approved_points_cost = @FinalPointsCost,
            status = 'approved',
            approved_at = SYSUTCDATETIME(),
            internal_notes = @DecisionNotes,
            decided_by_user_id = @DecidedByUserId,
            updated_at = SYSUTCDATETIME()
        WHERE id = @RedemptionId;

        IF @LedgerEventId IS NULL
            SET @LedgerEventId = NEWID();

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
        VALUES
        (
            @LedgerEventId,
            @ClientId,
            'reward_redemption',
            'debit',
            'redemption',
            CONVERT(varchar(100), @RedemptionId),
            NULL,
            NULL,
            @RewardId,
            NULL,
            (@FinalPointsCost * -1),
            NULL,
            NULL,
            NULL,
            SYSUTCDATETIME(),
            SYSUTCDATETIME(),
            NULL,
            0,
            CONCAT('Resgate aprovado: ', ISNULL(@RewardTitle, 'reward')),
            SYSUTCDATETIME(),
            @DecidedByUserId
        );

        EXEC dbo.usp_customer_loyalty_balance_rebuild
            @ClientId = @ClientId;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        THROW;
    END CATCH;

    SELECT *
    FROM dbo.loyalty_redemptions
    WHERE id = @RedemptionId;
END
GO

