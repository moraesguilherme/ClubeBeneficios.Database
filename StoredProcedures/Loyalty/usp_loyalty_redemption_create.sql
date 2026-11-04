
CREATE PROCEDURE [dbo].[usp_loyalty_redemption_create]
    @RedemptionId uniqueidentifier,
    @ClientId uniqueidentifier,
    @RewardId uniqueidentifier,
    @RequestedPointsCost int,
    @RequestChannel varchar(30) = NULL,
    @Notes varchar(1500) = NULL,
    @RequestedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RewardStatus varchar(30);
    DECLARE @RewardPointsCost int;

    SELECT
        @RewardStatus = r.status,
        @RewardPointsCost = r.points_cost
    FROM dbo.loyalty_rewards r
    WHERE r.id = @RewardId;

    IF @RewardStatus IS NULL
    BEGIN
        RAISERROR('Recompensa nao encontrada.', 16, 1);
        RETURN;
    END;

    IF @RewardStatus NOT IN ('active', 'scheduled')
    BEGIN
        RAISERROR(
            'Recompensa nao esta disponivel para solicitacao de resgate.',
            16, 1
        );
        RETURN;
    END;

    IF @RequestedPointsCost IS NULL
       OR @RequestedPointsCost <= 0
    BEGIN
        RAISERROR(
            'O custo da recompensa deve ser maior que zero.',
            16, 1
        );
        RETURN;
    END;

    IF @RequestedPointsCost <> @RewardPointsCost
    BEGIN
        RAISERROR(
            'O custo solicitado difere do custo atual da recompensa.',
            16, 1
        );
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.loyalty_redemptions WITH (UPDLOCK, HOLDLOCK)
            WHERE client_id = @ClientId
              AND reward_id = @RewardId
              AND status IN ('requested', 'under_review', 'approved')
        )
        BEGIN
            RAISERROR(
                'Voce ja possui uma solicitacao em andamento para esta recompensa.',
                16, 1
            );
        END;

        -- 3. Registrar a nova solicitacao
        INSERT INTO dbo.loyalty_redemptions
        (
            id,
            client_id,
            reward_id,
            redemption_code,
            requested_points_cost,
            approved_points_cost,
            status,
            request_channel,
            requested_at,
            approved_at,
            rejected_at,
            canceled_at,
            used_at,
            completed_at,
            expires_at,
            notes,
            internal_notes,
            requested_by_user_id,
            decided_by_user_id,
            created_at,
            updated_at,
            scheduled_for
        )
        VALUES
        (
            @RedemptionId,
            @ClientId,
            @RewardId,
            NULL,
            @RequestedPointsCost,
            NULL,
            'requested',
            @RequestChannel,
            SYSUTCDATETIME(),
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            @Notes,
            NULL,
            @RequestedByUserId,
            NULL,
            SYSUTCDATETIME(),
            SYSUTCDATETIME(),
            NULL
        );

        EXEC dbo.usp_loyalty_redemption_notification_enqueue
            @RedemptionId = @RedemptionId,
            @EventType = 'loyalty.redemption.requested';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage nvarchar(2048);
        SET @ErrorMessage = ERROR_MESSAGE();

        RAISERROR('%s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH;

    SELECT *
    FROM dbo.loyalty_redemptions
    WHERE id = @RedemptionId;
END
GO
