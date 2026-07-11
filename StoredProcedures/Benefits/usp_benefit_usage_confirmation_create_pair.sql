CREATE   PROCEDURE [dbo].[usp_benefit_usage_confirmation_create_pair]
    @BenefitRequestId UNIQUEIDENTIFIER,
    @ClientTokenHash VARCHAR(300),
    @PartnerTokenHash VARCHAR(300),
    @ClientConfirmationUrl VARCHAR(1000),
    @PartnerConfirmationUrl VARCHAR(1000),
    @ConfirmationExpiresAt DATETIME2(7),
    @PartnerRecipientEmail VARCHAR(320),
    @PartnerRecipientName VARCHAR(180) = NULL,
    @CreatedByUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    DECLARE
        @BenefitId UNIQUEIDENTIFIER,
        @PartnerId UNIQUEIDENTIFIER,
        @BenefitTitle VARCHAR(180),
        @BenefitDirection VARCHAR(30),
        @PartnerName VARCHAR(150),
        @RequestStatus VARCHAR(30),
        @RequesterType VARCHAR(30),
        @RequesterName VARCHAR(180),
        @RequesterEmail VARCHAR(320),
        @PetName VARCHAR(180),
        @RequestedAt DATETIME2(7),
        @EffectivePartnerRecipientName VARCHAR(180);

    DECLARE
        @ClientConfirmationId UNIQUEIDENTIFIER = NEWID(),
        @PartnerConfirmationId UNIQUEIDENTIFIER = NEWID(),
        @ClientNotificationId UNIQUEIDENTIFIER,
        @PartnerNotificationId UNIQUEIDENTIFIER;

    SELECT
        @BenefitId = r.benefit_id,
        @PartnerId = r.partner_id,
        @BenefitTitle = b.title,
        @BenefitDirection = b.direction,
        @PartnerName = p.trade_name,
        @RequestStatus = r.request_status,
        @RequesterType = r.requester_type,
        @RequestedAt = r.requested_at,
        @RequesterName =
            CASE
                WHEN r.requester_type = 'client'
                    THEN COALESCE(c.full_name, u.name, 'Cliente Matilha')
                WHEN r.requester_type = 'partner_customer'
                    THEN COALESCE(pc.full_name, 'Cliente do parceiro')
                ELSE 'Solicitante'
            END,
        @RequesterEmail =
            CASE
                WHEN r.requester_type = 'client'
                    THEN COALESCE(c.email, u.email)
                WHEN r.requester_type = 'partner_customer'
                    THEN pc.email
                ELSE NULL
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

    SET @EffectivePartnerRecipientName = COALESCE(@PartnerRecipientName, @PartnerName, 'Parceiro');

    IF @BenefitId IS NULL
    BEGIN
        RAISERROR('Solicitação de benefício não encontrada.', 16, 1);
        RETURN;
    END

    IF @BenefitDirection <> 'partner_to_matilha'
    BEGIN
        RAISERROR('Confirmação dupla de utilização é permitida apenas para benefícios ofertados por parceiro ao Cliente Matilha.', 16, 1);
        RETURN;
    END

    IF @RequesterType <> 'client'
    BEGIN
        RAISERROR('Confirmação cliente/parceiro exige solicitação de Cliente Matilha.', 16, 1);
        RETURN;
    END

    IF @RequestStatus NOT IN ('approved', 'scheduled')
    BEGIN
        RAISERROR('A solicitação precisa estar aprovada ou agendada para gerar confirmação de utilização.', 16, 1);
        RETURN;
    END

    IF @RequesterEmail IS NULL OR LTRIM(RTRIM(@RequesterEmail)) = ''
    BEGIN
        RAISERROR('Cliente não possui e-mail para envio de confirmação.', 16, 1);
        RETURN;
    END

    IF @PartnerRecipientEmail IS NULL OR LTRIM(RTRIM(@PartnerRecipientEmail)) = ''
    BEGIN
        RAISERROR('Parceiro não possui e-mail para envio de confirmação.', 16, 1);
        RETURN;
    END

    IF @ClientTokenHash IS NULL OR LTRIM(RTRIM(@ClientTokenHash)) = ''
    BEGIN
        RAISERROR('Hash do token do cliente é obrigatório.', 16, 1);
        RETURN;
    END

    IF @PartnerTokenHash IS NULL OR LTRIM(RTRIM(@PartnerTokenHash)) = ''
    BEGIN
        RAISERROR('Hash do token do parceiro é obrigatório.', 16, 1);
        RETURN;
    END

    IF @ClientTokenHash = @PartnerTokenHash
    BEGIN
        RAISERROR('Os hashes dos tokens de cliente e parceiro devem ser diferentes.', 16, 1);
        RETURN;
    END

    IF @ConfirmationExpiresAt <= @Now
    BEGIN
        RAISERROR('Data de expiração da confirmação deve ser futura.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM dbo.benefit_usage_confirmations
        WHERE benefit_request_id = @BenefitRequestId
          AND confirmation_status = 'pending'
    )
    BEGIN
        RAISERROR('Esta solicitação já possui confirmações pendentes.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM dbo.benefit_usages
        WHERE benefit_request_id = @BenefitRequestId
          AND usage_status IN ('confirmed', 'used')
    )
    BEGIN
        RAISERROR('Esta solicitação já possui utilização registrada.', 16, 1);
        RETURN;
    END

    DECLARE @ClientPayloadJson NVARCHAR(MAX);
    DECLARE @PartnerPayloadJson NVARCHAR(MAX);

    SELECT
        @ClientPayloadJson =
        (
            SELECT
                @RequesterName AS requesterName,
                @BenefitTitle AS benefitTitle,
                @PartnerName AS partnerName,
                CONVERT(VARCHAR(10), @RequestedAt, 103) AS requestedAt,
                @ClientConfirmationUrl AS confirmationUrl,
                CONVERT(VARCHAR(10), @ConfirmationExpiresAt, 103) + ' ' + CONVERT(VARCHAR(5), @ConfirmationExpiresAt, 108) AS confirmationExpiresAt
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

    SELECT
        @PartnerPayloadJson =
        (
            SELECT
                @EffectivePartnerRecipientName AS partnerName,
                @RequesterName AS requesterName,
                @BenefitTitle AS benefitTitle,
                COALESCE(@PetName, 'Pet não informado') AS petName,
                CONVERT(VARCHAR(10), @RequestedAt, 103) AS requestedAt,
                @PartnerConfirmationUrl AS confirmationUrl,
                CONVERT(VARCHAR(10), @ConfirmationExpiresAt, 103) + ' ' + CONVERT(VARCHAR(5), @ConfirmationExpiresAt, 108) AS confirmationExpiresAt
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.benefit_usage_confirmations
        (
            id,
            benefit_request_id,
            benefit_usage_id,
            benefit_id,
            partner_id,
            confirmation_type,
            confirmation_status,
            recipient_email,
            recipient_name,
            token_hash,
            expires_at,
            created_at,
            updated_at
        )
        VALUES
        (
            @ClientConfirmationId,
            @BenefitRequestId,
            NULL,
            @BenefitId,
            @PartnerId,
            'client',
            'pending',
            @RequesterEmail,
            @RequesterName,
            @ClientTokenHash,
            @ConfirmationExpiresAt,
            @Now,
            @Now
        );

        INSERT INTO dbo.benefit_usage_confirmations
        (
            id,
            benefit_request_id,
            benefit_usage_id,
            benefit_id,
            partner_id,
            confirmation_type,
            confirmation_status,
            recipient_email,
            recipient_name,
            token_hash,
            expires_at,
            created_at,
            updated_at
        )
        VALUES
        (
            @PartnerConfirmationId,
            @BenefitRequestId,
            NULL,
            @BenefitId,
            @PartnerId,
            'partner',
            'pending',
            @PartnerRecipientEmail,
            @EffectivePartnerRecipientName,
            @PartnerTokenHash,
            @ConfirmationExpiresAt,
            @Now,
            @Now
        );

        DECLARE @ClientNotificationResult TABLE
        (
            notification_id UNIQUEIDENTIFIER NULL
        );

        INSERT INTO @ClientNotificationResult
        EXEC dbo.usp_notification_enqueue_email
            @Module = 'benefits',
            @EventType = 'benefits.usage.confirmation.client',
            @AggregateType = 'benefit_request',
            @AggregateId = @BenefitRequestId,
            @TemplateKey = 'benefits.usage.confirmation.client',
            @RecipientType = 'client',
            @RecipientEmail = @RequesterEmail,
            @RecipientName = @RequesterName,
            @PayloadJson = @ClientPayloadJson,
            @Priority = 2,
            @IdempotencyKey = NULL;

        SELECT TOP 1
            @ClientNotificationId = notification_id
        FROM @ClientNotificationResult;

        DECLARE @PartnerNotificationResult TABLE
        (
            notification_id UNIQUEIDENTIFIER NULL
        );

        INSERT INTO @PartnerNotificationResult
        EXEC dbo.usp_notification_enqueue_email
            @Module = 'benefits',
            @EventType = 'benefits.usage.confirmation.partner',
            @AggregateType = 'benefit_request',
            @AggregateId = @BenefitRequestId,
            @TemplateKey = 'benefits.usage.confirmation.partner',
            @RecipientType = 'partner',
            @RecipientEmail = @PartnerRecipientEmail,
            @RecipientName = @EffectivePartnerRecipientName,
            @PayloadJson = @PartnerPayloadJson,
            @Priority = 2,
            @IdempotencyKey = NULL;

        SELECT TOP 1
            @PartnerNotificationId = notification_id
        FROM @PartnerNotificationResult;

        UPDATE dbo.benefit_usage_confirmations
        SET
            notification_id = @ClientNotificationId,
            updated_at = @Now
        WHERE id = @ClientConfirmationId;

        UPDATE dbo.benefit_usage_confirmations
        SET
            notification_id = @PartnerNotificationId,
            updated_at = @Now
        WHERE id = @PartnerConfirmationId;

        EXEC dbo.usp_benefit_request_timeline_event_add
            @BenefitRequestId = @BenefitRequestId,
            @EventType = 'review_added',
            @EventStatus = @RequestStatus,
            @EventPoint = 'usage_confirmation',
            @EventDescription = 'Confirmações de utilização enviadas para cliente e parceiro.',
            @ActorUserId = @CreatedByUserId,
            @OccurredAt = @Now;

        COMMIT TRANSACTION;

        SELECT
            @BenefitRequestId AS benefit_request_id,
            @ClientConfirmationId AS client_confirmation_id,
            @PartnerConfirmationId AS partner_confirmation_id,
            @ClientNotificationId AS client_notification_id,
            @PartnerNotificationId AS partner_notification_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO

