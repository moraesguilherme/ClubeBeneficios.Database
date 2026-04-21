CREATE   PROCEDURE [dbo].[usp_loyalty_redemption_create]
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
        RAISERROR('Reward nao encontrado.', 16, 1);
        RETURN;
    END

    IF @RewardStatus NOT IN ('active', 'scheduled')
    BEGIN
        RAISERROR('Reward nao esta disponivel para solicitacao de resgate.', 16, 1);
        RETURN;
    END

    IF @RequestedPointsCost IS NULL OR @RequestedPointsCost <= 0
    BEGIN
        RAISERROR('RequestedPointsCost deve ser maior que zero.', 16, 1);
        RETURN;
    END

    IF @RequestedPointsCost <> @RewardPointsCost
    BEGIN
        RAISERROR('RequestedPointsCost difere do custo atual configurado para o reward.', 16, 1);
        RETURN;
    END

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
        updated_at
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
        SYSUTCDATETIME()
    );

    SELECT *
    FROM dbo.loyalty_redemptions
    WHERE id = @RedemptionId;
END
GO


