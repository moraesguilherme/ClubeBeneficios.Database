CREATE   PROCEDURE [dbo].[usp_benefit_notification_enqueue]
    @BenefitId UNIQUEIDENTIFIER,
    @EventType VARCHAR(120),
    @PreviousStatus VARCHAR(30) = NULL,
    @Reason VARCHAR(1500) = NULL,
    @EventReferenceId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @BenefitTitle VARCHAR(180),
        @BenefitStatus VARCHAR(30),
        @Direction VARCHAR(30),
        @PartnerId UNIQUEIDENTIFIER,
        @PartnerName VARCHAR(150),
        @PartnerEmail VARCHAR(320),
        @PayloadJson NVARCHAR(MAX),
        @PartnerTemplateKey VARCHAR(120),
        @AdminTemplateKey VARCHAR(120),
        @PartnerIdempotencyKey VARCHAR(250),
        @AdminIdempotencyPrefix VARCHAR(200),
        @AdminEventType VARCHAR(120),
        @DirectionLabel VARCHAR(120),
        @StatusLabel VARCHAR(120),
        @PreviousStatusLabel VARCHAR(120);

    DECLARE @NotificationResult TABLE
    (
        notification_id UNIQUEIDENTIFIER NULL
    );

    SELECT
        @BenefitTitle = b.title,
        @BenefitStatus = b.status,
        @Direction = b.direction,
        @PartnerId = b.partner_id,
        @PartnerName = p.trade_name,
        @PartnerEmail = p.email
    FROM dbo.benefits b
    INNER JOIN dbo.partners p
        ON p.id = b.partner_id
    WHERE b.id = @BenefitId;

    IF @BenefitTitle IS NULL
        RETURN;

    SET @DirectionLabel =
        CASE
            WHEN @Direction = 'partner_to_matilha' THEN 'Parceiro para Cliente Matilha'
            WHEN @Direction = 'matilha_to_partner' THEN 'Matilha para Cliente do Parceiro'
            ELSE COALESCE(@Direction, 'Não informado')
        END;

    SET @StatusLabel =
        CASE
            WHEN @BenefitStatus = 'pending_review' THEN 'Pendente de análise'
            WHEN @BenefitStatus = 'under_review' THEN 'Ajuste solicitado'
            WHEN @BenefitStatus = 'approved' THEN 'Aprovado'
            WHEN @BenefitStatus = 'active' THEN 'Ativo'
            WHEN @BenefitStatus = 'rejected' THEN 'Rejeitado'
            WHEN @BenefitStatus = 'inactive' THEN 'Inativo'
            WHEN @BenefitStatus = 'archived' THEN 'Arquivado'
            WHEN @BenefitStatus = 'expired' THEN 'Expirado'
            ELSE COALESCE(@BenefitStatus, 'Não informado')
        END;

    SET @PreviousStatusLabel =
        CASE
            WHEN @PreviousStatus = 'pending_review' THEN 'Pendente de análise'
            WHEN @PreviousStatus = 'under_review' THEN 'Ajuste solicitado'
            WHEN @PreviousStatus = 'approved' THEN 'Aprovado'
            WHEN @PreviousStatus = 'active' THEN 'Ativo'
            WHEN @PreviousStatus = 'rejected' THEN 'Rejeitado'
            WHEN @PreviousStatus = 'inactive' THEN 'Inativo'
            WHEN @PreviousStatus = 'archived' THEN 'Arquivado'
            WHEN @PreviousStatus = 'expired' THEN 'Expirado'
            ELSE COALESCE(@PreviousStatus, 'Não informado')
        END;

    SELECT
        @PayloadJson =
        (
            SELECT
                @BenefitTitle AS benefitTitle,
                @BenefitStatus AS status,
                @StatusLabel AS statusLabel,
                @PreviousStatus AS previousStatus,
                @PreviousStatusLabel AS previousStatusLabel,
                @Direction AS direction,
                @DirectionLabel AS directionLabel,
                @PartnerName AS partnerName,
                COALESCE(@Reason, '') AS reason
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

    IF @EventType = 'benefits.benefit.submitted'
    BEGIN
        SET @PartnerTemplateKey = 'benefits.benefit.submitted.partner';
        SET @AdminTemplateKey = 'benefits.benefit.submitted.admin';
        SET @AdminEventType = 'benefits.benefit.submitted.admin';
    END
    ELSE IF @EventType = 'benefits.benefit.status_changed'
    BEGIN
        SET @PartnerTemplateKey = 'benefits.benefit.status_changed.partner';
        SET @AdminTemplateKey = 'benefits.benefit.status_changed.admin';
        SET @AdminEventType = 'benefits.benefit.status_changed.admin';
    END
    ELSE
    BEGIN
        RETURN;
    END

    SET @PartnerIdempotencyKey =
        CASE
            WHEN @EventReferenceId IS NOT NULL THEN
                CONCAT(@EventType, ':', CONVERT(VARCHAR(36), @BenefitId), ':', CONVERT(VARCHAR(36), @EventReferenceId), ':partner')
            ELSE
                CONCAT(@EventType, ':', CONVERT(VARCHAR(36), @BenefitId), ':', COALESCE(@BenefitStatus, 'unknown'), ':partner')
        END;

    SET @AdminIdempotencyPrefix =
        CASE
            WHEN @EventReferenceId IS NOT NULL THEN
                CONCAT(@EventType, ':', CONVERT(VARCHAR(36), @BenefitId), ':', CONVERT(VARCHAR(36), @EventReferenceId), ':admin')
            ELSE
                CONCAT(@EventType, ':', CONVERT(VARCHAR(36), @BenefitId), ':', COALESCE(@BenefitStatus, 'unknown'), ':admin')
        END;

    IF @PartnerEmail IS NOT NULL AND LTRIM(RTRIM(@PartnerEmail)) <> ''
    BEGIN
        INSERT INTO @NotificationResult
        EXEC dbo.usp_notification_enqueue_email
            @Module = 'benefits',
            @EventType = @EventType,
            @AggregateType = 'benefit',
            @AggregateId = @BenefitId,
            @TemplateKey = @PartnerTemplateKey,
            @RecipientType = 'partner',
            @RecipientEmail = @PartnerEmail,
            @RecipientName = @PartnerName,
            @PayloadJson = @PayloadJson,
            @Priority = 3,
            @IdempotencyKey = @PartnerIdempotencyKey;
    END

    EXEC dbo.usp_notification_enqueue_configured_recipients
        @Module = 'benefits',
        @EventType = @AdminEventType,
        @AggregateType = 'benefit',
        @AggregateId = @BenefitId,
        @TemplateKey = @AdminTemplateKey,
        @PayloadJson = @PayloadJson,
        @Priority = 3,
        @IdempotencyPrefix = @AdminIdempotencyPrefix;
END
GO

