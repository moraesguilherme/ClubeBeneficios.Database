
CREATE PROCEDURE [dbo].[usp_loyalty_redemption_notification_enqueue]
    @RedemptionId UNIQUEIDENTIFIER,
    @EventType VARCHAR(120),
    @EventReferenceId UNIQUEIDENTIFIER = NULL,
    @PreviousStatus VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @CustomerName VARCHAR(180),
        @CustomerEmail VARCHAR(320),
        @RewardTitle VARCHAR(180),
        @PointsCost INT,
        @RedemptionStatus VARCHAR(30),
        @RequestedAt DATETIME2(7),
        @StatusLabel VARCHAR(120),

        @PayloadJson NVARCHAR(MAX),

        @ClientTemplateKey VARCHAR(120),
        @AdminTemplateKey VARCHAR(120),
        @AdminEventType VARCHAR(120),

        @ClientIdempotencyKey VARCHAR(250),
        @AdminIdempotencyPrefix VARCHAR(200),

        @ApprovedPointsCost INT,
        @StatusMessage VARCHAR(500),
        @UsedAt DATETIME2(7),
        @ExpiresAt DATETIME2(7);

    DECLARE @NotificationResult TABLE
    (
        notification_id UNIQUEIDENTIFIER NULL
    );

    SELECT
        @CustomerName = COALESCE(
            NULLIF(LTRIM(RTRIM(c.full_name)), ''),
            NULLIF(LTRIM(RTRIM(u.name)), ''),
            'Cliente Matilha'
        ),

        @CustomerEmail = COALESCE(
            NULLIF(LTRIM(RTRIM(c.email)), ''),
            NULLIF(LTRIM(RTRIM(u.email)), '')
        ),

        @RewardTitle = rw.title,
        @PointsCost = r.requested_points_cost,
        @RedemptionStatus = r.status,
        @RequestedAt = r.requested_at,
        @UsedAt = r.used_at,
        @ExpiresAt = r.expires_at,
        @ApprovedPointsCost = r.approved_points_cost

    FROM dbo.loyalty_redemptions r

    INNER JOIN dbo.clients c
        ON c.id = r.client_id

    LEFT JOIN dbo.users u
        ON u.id = c.user_id

    INNER JOIN dbo.loyalty_rewards rw
        ON rw.id = r.reward_id

    WHERE r.id = @RedemptionId;

    IF @RedemptionStatus IS NULL
        RETURN;

    IF @EventType = 'loyalty.redemption.requested'
    BEGIN
        IF @RedemptionStatus <> 'requested'
            RETURN;

        SET @StatusLabel = 'Solicitado';

        SET @ClientTemplateKey =
            'loyalty.redemption.requested.client';

        SET @AdminTemplateKey =
            'loyalty.redemption.requested.admin';

        SET @AdminEventType =
            'loyalty.redemption.requested.admin';
    END
    ELSE IF @EventType = 'loyalty.redemption.rejected'
    BEGIN
        IF @RedemptionStatus <> 'rejected'
            RETURN;

        SET @StatusLabel = 'Rejeitado';

        SET @ClientTemplateKey =
            'loyalty.redemption.rejected.client';

        SET @AdminTemplateKey = NULL;
        SET @AdminEventType = NULL;
    END
    ELSE IF @EventType = 'loyalty.redemption.canceled'
    BEGIN
        IF @RedemptionStatus <> 'canceled'
            RETURN;

        SET @StatusLabel = 'Cancelado';

        SET @ClientTemplateKey =
            'loyalty.redemption.canceled.client';

        SET @AdminTemplateKey = NULL;
        SET @AdminEventType = NULL;

        IF @PreviousStatus = 'approved'
           AND ISNULL(@ApprovedPointsCost, 0) > 0
        BEGIN
            SET @StatusMessage =
                'Os pontos debitados na aprovacao foram devolvidos ao seu saldo de fidelidade.';
        END
        ELSE
        BEGIN
            SET @StatusMessage =
                'Esta solicitacao foi cancelada sem necessidade de devolucao de pontos.';
        END;
    END
    ELSE IF @EventType = 'loyalty.redemption.approved'
    BEGIN
        IF @RedemptionStatus <> 'approved'
            RETURN;

        SET @StatusLabel = 'Aprovado';

        SET @ClientTemplateKey =
            'loyalty.redemption.approved.client';

        SET @AdminTemplateKey = NULL;
        SET @AdminEventType = NULL;
    END
    
    ELSE IF @EventType = 'loyalty.redemption.used'
    BEGIN
        IF @RedemptionStatus <> 'used'
            RETURN;

        SET @StatusLabel = 'Utilizado';

        SET @ClientTemplateKey =
            'loyalty.redemption.used.client';

        SET @AdminTemplateKey = NULL;
        SET @AdminEventType = NULL;
    END
    ELSE IF @EventType = 'loyalty.redemption.expired'
    BEGIN
        IF @RedemptionStatus <> 'expired'
            RETURN;

        SET @StatusLabel = 'Expirado';

        SET @ClientTemplateKey =
            'loyalty.redemption.expired.client';

        SET @AdminTemplateKey = NULL;
        SET @AdminEventType = NULL;
    END
    ELSE
    BEGIN
        RETURN;
    END;

    SELECT
        @PayloadJson =
        (
            SELECT
                CONVERT(VARCHAR(36), @RedemptionId)
                    AS redemptionId,

                @CustomerName
                    AS customerName,

                @RewardTitle
                    AS rewardTitle,

                @PointsCost
                    AS pointsCost,

                @ApprovedPointsCost 
                    AS approvedPointsCost,

                @RedemptionStatus
                    AS status,

                @StatusLabel
                    AS statusLabel,

                CONVERT(VARCHAR(10), @RequestedAt, 103)
                    AS requestedAt,

                CONVERT(VARCHAR(10), @UsedAt, 103) 
                    AS usedAt,

                CONVERT(VARCHAR(10), @ExpiresAt, 103) 
                    AS expiresAt,

                COALESCE(@StatusMessage, '') 
                    AS statusMessage

            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER 
        );

    SET @ClientIdempotencyKey =
        CASE
            WHEN @EventReferenceId IS NOT NULL THEN
                CONCAT(
                    @EventType, ':',
                    CONVERT(VARCHAR(36), @RedemptionId), ':',
                    CONVERT(VARCHAR(36), @EventReferenceId),
                    ':client'
                )
            ELSE
                CONCAT(
                    @EventType, ':',
                    CONVERT(VARCHAR(36), @RedemptionId),
                    ':client'
                )
        END;

    SET @AdminIdempotencyPrefix =
        CASE
            WHEN @EventReferenceId IS NOT NULL THEN
                CONCAT(
                    @EventType, ':',
                    CONVERT(VARCHAR(36), @RedemptionId), ':',
                    CONVERT(VARCHAR(36), @EventReferenceId),
                    ':admin'
                )
            ELSE
                CONCAT(
                    @EventType, ':',
                    CONVERT(VARCHAR(36), @RedemptionId),
                    ':admin'
                )
        END;

    IF @ClientTemplateKey IS NOT NULL
       AND @CustomerEmail IS NOT NULL
    BEGIN
        INSERT INTO @NotificationResult
        EXEC dbo.usp_notification_enqueue_email
            @Module = 'loyalty',
            @EventType = @EventType,
            @AggregateType = 'loyalty_redemption',
            @AggregateId = @RedemptionId,
            @TemplateKey = @ClientTemplateKey,
            @RecipientType = 'client',
            @RecipientEmail = @CustomerEmail,
            @RecipientName = @CustomerName,
            @PayloadJson = @PayloadJson,
            @Priority = 3,
            @IdempotencyKey = @ClientIdempotencyKey;
    END;

    IF @AdminTemplateKey IS NOT NULL
       AND @AdminEventType IS NOT NULL
    BEGIN
        EXEC dbo.usp_notification_enqueue_configured_recipients
            @Module = 'loyalty',
            @EventType = @AdminEventType,
            @AggregateType = 'loyalty_redemption',
            @AggregateId = @RedemptionId,
            @TemplateKey = @AdminTemplateKey,
            @PayloadJson = @PayloadJson,
            @Priority = 3,
            @IdempotencyPrefix = @AdminIdempotencyPrefix;
    END;
END
GO
