CREATE   PROCEDURE [dbo].[usp_benefit_request_notification_enqueue]
    @BenefitRequestId UNIQUEIDENTIFIER,
    @EventType VARCHAR(120),
    @ReviewPoint VARCHAR(200) = NULL,
    @ReviewRecommendation VARCHAR(1500) = NULL,
    @EventReferenceId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @BenefitId UNIQUEIDENTIFIER,
        @BenefitTitle VARCHAR(180),
        @PartnerId UNIQUEIDENTIFIER,
        @PartnerName VARCHAR(150),
        @PartnerEmail VARCHAR(320),
        @Direction VARCHAR(30),
        @RequesterType VARCHAR(30),
        @RequesterTypeLabel VARCHAR(120),
        @RequesterEmail VARCHAR(320),
        @RequesterName VARCHAR(180),
        @PetName VARCHAR(180),
        @RequestStatus VARCHAR(30),
        @RequestStatusLabel VARCHAR(120),
        @RequestedAt DATETIME2(7),
        @ExpiresAt DATETIME2(7),
        @UsedAt DATETIME2(7),
        @PayloadJson NVARCHAR(MAX),
        @RequesterTemplateKey VARCHAR(120),
        @PartnerTemplateKey VARCHAR(120),
        @AdminTemplateKey VARCHAR(120),
        @AdminConfiguredEventType VARCHAR(120),
        @RequesterIdempotencyKey VARCHAR(250),
        @PartnerIdempotencyKey VARCHAR(250),
        @AdminIdempotencyPrefix VARCHAR(200);

    DECLARE @NotificationResult TABLE
    (
        notification_id UNIQUEIDENTIFIER NULL
    );

    SELECT
        @BenefitId = r.benefit_id,
        @BenefitTitle = b.title,
        @PartnerId = r.partner_id,
        @PartnerName = p.trade_name,
        @PartnerEmail = p.email,
        @Direction = b.direction,
        @RequesterType = r.requester_type,
        @RequestStatus = r.request_status,
        @RequestedAt = r.requested_at,
        @ExpiresAt = r.expires_at,

        @RequesterEmail =
            CASE
                WHEN r.requester_type = 'client'
                    THEN COALESCE(c.email, u.email)
                WHEN r.requester_type = 'partner_customer'
                    THEN pc.email
                ELSE NULL
            END,

        @RequesterName =
            CASE
                WHEN r.requester_type = 'client'
                    THEN COALESCE(c.full_name, u.name, 'Cliente Matilha')
                WHEN r.requester_type = 'partner_customer'
                    THEN COALESCE(pc.full_name, 'Cliente do parceiro')
                ELSE 'Solicitante'
            END,

        @PetName =
            CASE
                WHEN r.pet_source_type = 'client_pet' THEN cp.name
                WHEN r.pet_source_type = 'partner_customer_pet' THEN pcp.name
                ELSE NULL
            END
    FROM dbo.benefit_requests r
    INNER JOIN dbo.benefits b
        ON b.id = r.benefit_id
    INNER JOIN dbo.partners p
        ON p.id = r.partner_id
    LEFT JOIN dbo.clients c
        ON c.id = r.requester_client_id
    LEFT JOIN dbo.partner_customers pc
        ON pc.id = r.requester_partner_customer_id
    LEFT JOIN dbo.users u
        ON u.id = r.requester_user_id
    LEFT JOIN dbo.client_pets cp
        ON cp.id = r.requester_client_pet_id
    LEFT JOIN dbo.partner_customer_pets pcp
        ON pcp.id = r.requester_partner_customer_pet_id
    WHERE r.id = @BenefitRequestId;

    IF @BenefitId IS NULL
        RETURN;

    SELECT TOP 1
        @UsedAt = u.used_at
    FROM dbo.benefit_usages u
    WHERE u.benefit_request_id = @BenefitRequestId
    ORDER BY u.used_at DESC, u.created_at DESC;

    SET @RequesterTypeLabel =
        CASE
            WHEN @RequesterType = 'client' THEN 'Cliente Matilha'
            WHEN @RequesterType = 'partner_customer' THEN 'Cliente do parceiro'
            ELSE COALESCE(@RequesterType, 'Solicitante')
        END;

    SET @RequestStatusLabel =
        CASE
            WHEN @RequestStatus = 'requested' THEN 'Solicitada'
            WHEN @RequestStatus = 'pending_review' THEN 'Pendente de análise'
            WHEN @RequestStatus = 'under_review' THEN 'Ajuste solicitado'
            WHEN @RequestStatus = 'approved' THEN 'Aprovada'
            WHEN @RequestStatus = 'declined' THEN 'Reprovada'
            WHEN @RequestStatus = 'rejected' THEN 'Reprovada'
            WHEN @RequestStatus = 'cancelled' THEN 'Cancelada'
            WHEN @RequestStatus = 'expired' THEN 'Expirada'
            WHEN @RequestStatus = 'scheduled' THEN 'Agendada'
            WHEN @RequestStatus = 'no_show' THEN 'Não compareceu'
            WHEN @RequestStatus = 'converted_to_usage' THEN 'Utilizada'
            ELSE COALESCE(@RequestStatus, 'Não informado')
        END;

    SELECT
        @PayloadJson =
        (
            SELECT
                @RequesterName AS requesterName,
                @RequesterEmail AS requesterEmail,
                @RequesterType AS requesterType,
                @RequesterTypeLabel AS requesterTypeLabel,
                @PetName AS petName,

                @BenefitTitle AS benefitTitle,
                @PartnerName AS partnerName,
                @Direction AS direction,

                @RequestStatus AS requestStatus,
                @RequestStatusLabel AS requestStatusLabel,

                CONVERT(VARCHAR(10), @RequestedAt, 103) AS requestedAt,
                CONVERT(VARCHAR(10), @ExpiresAt, 103) AS expiresAt,
                CONVERT(VARCHAR(10), @UsedAt, 103) AS usedAt,

                COALESCE(@ReviewPoint, '') AS reviewPoint,
                COALESCE(@ReviewRecommendation, '') AS reviewRecommendation
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

    IF @EventType = 'benefits.request.created'
    BEGIN
        SET @RequesterTemplateKey = 'benefits.request.created.requester';
        SET @PartnerTemplateKey = 'benefits.request.created.partner';
        SET @AdminTemplateKey = 'benefits.request.created.admin';
        SET @AdminConfiguredEventType = 'benefits.request.created.admin';
    END
    ELSE IF @EventType IN (
        'benefits.request.approved',
        'benefits.request.changes_requested',
        'benefits.request.rejected'
    )
    BEGIN
        SET @RequesterTemplateKey = 'benefits.request.status_changed.requester';
        SET @PartnerTemplateKey = 'benefits.request.status_changed.partner';
        SET @AdminTemplateKey = 'benefits.request.status_changed.admin';

        SET @AdminConfiguredEventType =
            CASE
                WHEN @EventType = 'benefits.request.approved' THEN 'benefits.request.approved.admin'
                WHEN @EventType = 'benefits.request.changes_requested' THEN 'benefits.request.changes_requested.admin'
                WHEN @EventType = 'benefits.request.rejected' THEN 'benefits.request.rejected.admin'
                ELSE NULL
            END;
    END
    ELSE IF @EventType = 'benefits.usage.registered'
    BEGIN
        SET @RequesterTemplateKey = 'benefits.usage.registered.requester';
        SET @PartnerTemplateKey = 'benefits.usage.registered.partner';
        SET @AdminTemplateKey = 'benefits.usage.registered.admin';
        SET @AdminConfiguredEventType = 'benefits.usage.registered.admin';
    END
    ELSE
    BEGIN
        RETURN;
    END

    SET @RequesterIdempotencyKey =
        CASE
            WHEN @EventReferenceId IS NOT NULL THEN
                CONCAT(@EventType, ':', CONVERT(VARCHAR(36), @BenefitRequestId), ':', CONVERT(VARCHAR(36), @EventReferenceId), ':requester')
            ELSE
                CONCAT(@EventType, ':', CONVERT(VARCHAR(36), @BenefitRequestId), ':requester')
        END;

    SET @PartnerIdempotencyKey =
        CASE
            WHEN @EventReferenceId IS NOT NULL THEN
                CONCAT(@EventType, ':', CONVERT(VARCHAR(36), @BenefitRequestId), ':', CONVERT(VARCHAR(36), @EventReferenceId), ':partner')
            ELSE
                CONCAT(@EventType, ':', CONVERT(VARCHAR(36), @BenefitRequestId), ':partner')
        END;

    SET @AdminIdempotencyPrefix =
        CASE
            WHEN @EventReferenceId IS NOT NULL THEN
                CONCAT(@EventType, ':', CONVERT(VARCHAR(36), @BenefitRequestId), ':', CONVERT(VARCHAR(36), @EventReferenceId), ':admin')
            ELSE
                CONCAT(@EventType, ':', CONVERT(VARCHAR(36), @BenefitRequestId), ':admin')
        END;

    IF @RequesterEmail IS NOT NULL AND LTRIM(RTRIM(@RequesterEmail)) <> ''
    BEGIN
        DELETE FROM @NotificationResult;

        INSERT INTO @NotificationResult
        EXEC dbo.usp_notification_enqueue_email
            @Module = 'benefits',
            @EventType = @EventType,
            @AggregateType = 'benefit_request',
            @AggregateId = @BenefitRequestId,
            @TemplateKey = @RequesterTemplateKey,
            @RecipientType = @RequesterType,
            @RecipientEmail = @RequesterEmail,
            @RecipientName = @RequesterName,
            @PayloadJson = @PayloadJson,
            @Priority = 3,
            @IdempotencyKey = @RequesterIdempotencyKey;
    END

    IF @PartnerEmail IS NOT NULL AND LTRIM(RTRIM(@PartnerEmail)) <> ''
    BEGIN
        DELETE FROM @NotificationResult;

        INSERT INTO @NotificationResult
        EXEC dbo.usp_notification_enqueue_email
            @Module = 'benefits',
            @EventType = @EventType,
            @AggregateType = 'benefit_request',
            @AggregateId = @BenefitRequestId,
            @TemplateKey = @PartnerTemplateKey,
            @RecipientType = 'partner',
            @RecipientEmail = @PartnerEmail,
            @RecipientName = @PartnerName,
            @PayloadJson = @PayloadJson,
            @Priority = 3,
            @IdempotencyKey = @PartnerIdempotencyKey;
    END

    IF @AdminConfiguredEventType IS NOT NULL
    BEGIN
        EXEC dbo.usp_notification_enqueue_configured_recipients
            @Module = 'benefits',
            @EventType = @AdminConfiguredEventType,
            @AggregateType = 'benefit_request',
            @AggregateId = @BenefitRequestId,
            @TemplateKey = @AdminTemplateKey,
            @PayloadJson = @PayloadJson,
            @Priority = 3,
            @IdempotencyPrefix = @AdminIdempotencyPrefix;
    END
END
GO

