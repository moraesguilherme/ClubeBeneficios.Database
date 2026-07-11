CREATE PROCEDURE [dbo].[usp_loyalty_redemption_cancel]
    @RedemptionId uniqueidentifier,
    @DecisionNotes varchar(1500) = NULL,
    @DecidedByUserId uniqueidentifier = NULL,
    @LedgerEventId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @CurrentStatus varchar(30),
        @ClientId uniqueidentifier,
        @RewardId uniqueidentifier,
        @ApprovedPointsCost int,
        @RewardTitle varchar(150);

    SELECT
        @CurrentStatus = r.status,
        @ClientId = r.client_id,
        @RewardId = r.reward_id,
        @ApprovedPointsCost = r.approved_points_cost
    FROM dbo.loyalty_redemptions r
    WHERE r.id = @RedemptionId;

    IF @CurrentStatus IS NULL
    BEGIN
        RAISERROR('Resgate nao encontrado.', 16, 1);
        RETURN;
    END

    IF @CurrentStatus IN ('canceled', 'completed', 'expired', 'used')
    BEGIN
        RAISERROR('Resgate nao pode ser cancelado no status atual.', 16, 1);
        RETURN;
    END

    SELECT
        @RewardTitle = title
    FROM dbo.loyalty_rewards
    WHERE id = @RewardId;

    BEGIN TRY
        BEGIN TRAN;

        UPDATE dbo.loyalty_redemptions
        SET
            status = 'canceled',
            canceled_at = SYSUTCDATETIME(),
            internal_notes = @DecisionNotes,
            decided_by_user_id = @DecidedByUserId,
            updated_at = SYSUTCDATETIME()
        WHERE id = @RedemptionId;

        IF @CurrentStatus = 'approved'
           AND ISNULL(@ApprovedPointsCost, 0) > 0
        BEGIN
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
                'credit',
                'redemption',
                CONVERT(varchar(100), @RedemptionId),
                NULL,
                NULL,
                @RewardId,
                NULL,
                @ApprovedPointsCost,
                NULL,
                NULL,
                NULL,
                SYSUTCDATETIME(),
                SYSUTCDATETIME(),
                NULL,
                0,
                CONCAT('Cancelamento de resgate aprovado: ', ISNULL(@RewardTitle, 'reward')),
                SYSUTCDATETIME(),
                @DecidedByUserId
            );

            EXEC dbo.usp_customer_loyalty_balance_rebuild
                @ClientId = @ClientId;
        END

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

