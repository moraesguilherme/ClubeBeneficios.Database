
CREATE PROCEDURE [dbo].[usp_loyalty_customer_redemption_create]
    @ClientId uniqueidentifier,
    @RequestedByUserId uniqueidentifier,
    @RewardId uniqueidentifier,
    @Notes varchar(1500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RedemptionId uniqueidentifier = NEWID();
    DECLARE @RewardStatus varchar(30);
    DECLARE @RewardPointsCost int;
    DECLARE @EligibleLevelCode varchar(30);
    DECLARE @AvailablePoints int;
    DECLARE @ClientLevelCode varchar(30);
    DECLARE @ClientLevelRank int;
    DECLARE @RewardLevelRank int;

    -- 1. Identificar a recompensa
    SELECT
        @RewardStatus = r.status,
        @RewardPointsCost = r.points_cost,
        @EligibleLevelCode = r.eligible_level_code
    FROM dbo.loyalty_rewards r
    WHERE r.id = @RewardId;

    IF @RewardStatus IS NULL
    BEGIN
        RAISERROR('Recompensa nao encontrada.', 16, 1);
        RETURN;
    END;

    IF @RewardStatus <> 'active'
    BEGIN
        RAISERROR('Recompensa nao esta ativa para resgate.', 16, 1);
        RETURN;
    END;

    -- 2. Validar saldo disponível
    SELECT
        @AvailablePoints = ISNULL(b.available_points, 0)
    FROM dbo.customer_loyalty_balances b
    WHERE b.client_id = @ClientId;

    SET @AvailablePoints = ISNULL(@AvailablePoints, 0);

    IF @AvailablePoints < @RewardPointsCost
    BEGIN
        RAISERROR('Pontos insuficientes para resgatar esta recompensa.', 16, 1);
        RETURN;
    END;

    -- 3. Consultar nível atual do cliente
    SELECT TOP (1)
        @ClientLevelCode = COALESCE(m.level_code, h.to_level_code)
    FROM dbo.clients c
    OUTER APPLY
    (
        SELECT TOP (1)
            s.level_code
        FROM dbo.customer_loyalty_metric_snapshots s
        WHERE s.client_id = c.id
        ORDER BY s.calculated_at DESC, s.created_at DESC
    ) m
    OUTER APPLY
    (
        SELECT TOP (1)
            lh.to_level_code
        FROM dbo.loyalty_level_history lh
        WHERE lh.client_id = c.id
        ORDER BY lh.changed_at DESC, lh.created_at DESC
    ) h
    WHERE c.id = @ClientId;

    SET @ClientLevelCode = ISNULL(@ClientLevelCode, 'bronze');

    -- 4. Validar elegibilidade por nível
    IF @EligibleLevelCode IS NOT NULL
    BEGIN
        SET @ClientLevelRank =
            CASE @ClientLevelCode
                WHEN 'bronze' THEN 1
                WHEN 'silver' THEN 2
                WHEN 'gold' THEN 3
                WHEN 'diamond' THEN 4
                ELSE 1
            END;

        SET @RewardLevelRank =
            CASE @EligibleLevelCode
                WHEN 'bronze' THEN 1
                WHEN 'silver' THEN 2
                WHEN 'gold' THEN 3
                WHEN 'diamond' THEN 4
                ELSE NULL
            END;

        IF @RewardLevelRank IS NOT NULL
           AND @ClientLevelRank < @RewardLevelRank
        BEGIN
            RAISERROR(
                'Seu nivel atual ainda nao permite resgatar esta recompensa.',
                16,
                1
            );
            RETURN;
        END;
    END;

    -- 5. Criar solicitação pela procedure existente
    EXEC dbo.usp_loyalty_redemption_create
        @RedemptionId = @RedemptionId,
        @ClientId = @ClientId,
        @RewardId = @RewardId,
        @RequestedPointsCost = @RewardPointsCost,
        @RequestChannel = 'client_portal',
        @Notes = @Notes,
        @RequestedByUserId = @RequestedByUserId;

    -- 6. Retornar informações para o Cliente Matilha
    SELECT TOP (1)
        r.id,
        r.client_id,
        r.reward_id,

        rw.title AS reward_title,
        rw.description AS reward_description,

        r.redemption_code,
        r.requested_points_cost,
        r.approved_points_cost,
        r.status,
        r.request_channel,

        r.requested_at,
        r.approved_at,
        r.rejected_at,
        r.canceled_at,
        r.used_at,
        r.completed_at,
        r.expires_at,
        r.scheduled_for,

        r.notes,
        r.created_at,
        r.updated_at,

        rw.availability_summary,
        rw.operational_rule_summary,
        rw.eligible_level_code,
        rw.redemption_mode,
        rw.minimum_notice_hours,
        rw.cumulative_mode,
        rw.usage_window_type,
        rw.usage_window_value,
        rw.availability_type,
        rw.season_type,
        rw.is_transferable

    FROM dbo.loyalty_redemptions r
    INNER JOIN dbo.loyalty_rewards rw
        ON rw.id = r.reward_id
    WHERE r.id = @RedemptionId
      AND r.client_id = @ClientId;
END
GO
