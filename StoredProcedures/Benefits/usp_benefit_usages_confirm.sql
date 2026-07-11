CREATE   PROCEDURE [dbo].[usp_benefit_usages_confirm]
    @BenefitId UNIQUEIDENTIFIER,
    @BenefitRequestId UNIQUEIDENTIFIER = NULL,

    @UsedByType VARCHAR(30) = NULL,
    @UsedByUserId UNIQUEIDENTIFIER = NULL,                    -- legado
    @UsedByClientId UNIQUEIDENTIFIER = NULL,
    @UsedByPartnerCustomerId UNIQUEIDENTIFIER = NULL,

    @PetSourceType VARCHAR(30) = NULL,
    @ClientPetId UNIQUEIDENTIFIER = NULL,
    @PartnerCustomerPetId UNIQUEIDENTIFIER = NULL,

    @RecordedByUserId UNIQUEIDENTIFIER = NULL,
    @ConfirmedByPartnerUserId UNIQUEIDENTIFIER = NULL,
    @ConfirmedByAdminUserId UNIQUEIDENTIFIER = NULL,

    @MonetaryValue DECIMAL(18,2) = NULL,
    @DiscountValue DECIMAL(18,2) = NULL,
    @RuleSummary VARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();
    DECLARE @BenefitUsageId UNIQUEIDENTIFIER = NEWID();

    DECLARE @PartnerId UNIQUEIDENTIFIER;
    DECLARE @BenefitStatus VARCHAR(30);
    DECLARE @Title VARCHAR(180);
    DECLARE @PartnerName VARCHAR(150);

    DECLARE @RequestBenefitId UNIQUEIDENTIFIER;
    DECLARE @RequestPartnerId UNIQUEIDENTIFIER;
    DECLARE @RequestStatus VARCHAR(30);
    DECLARE @RequestExpiresAt DATETIME2(7);

    DECLARE @RequestRequesterType VARCHAR(30);
    DECLARE @RequestRequesterUserId UNIQUEIDENTIFIER;
    DECLARE @RequestRequesterClientId UNIQUEIDENTIFIER;
    DECLARE @RequestRequesterPartnerCustomerId UNIQUEIDENTIFIER;

    DECLARE @RequestPetSourceType VARCHAR(30);
    DECLARE @RequestClientPetId UNIQUEIDENTIFIER;
    DECLARE @RequestPartnerCustomerPetId UNIQUEIDENTIFIER;

    SELECT
        @PartnerId = b.partner_id,
        @BenefitStatus = b.status,
        @Title = b.title,
        @PartnerName = p.trade_name
    FROM dbo.benefits b
    INNER JOIN dbo.partners p
        ON p.id = b.partner_id
    WHERE b.id = @BenefitId;

    IF @PartnerId IS NULL
    BEGIN
        RAISERROR('Benefício não encontrado.', 16, 1);
        RETURN;
    END

    IF @BenefitStatus NOT IN ('active', 'approved')
    BEGIN
        RAISERROR('Benefício não está disponível para utilização.', 16, 1);
        RETURN;
    END

    IF @MonetaryValue IS NOT NULL AND @MonetaryValue < 0
    BEGIN
        RAISERROR('MonetaryValue não pode ser negativo.', 16, 1);
        RETURN;
    END

    IF @DiscountValue IS NOT NULL AND @DiscountValue < 0
    BEGIN
        RAISERROR('DiscountValue não pode ser negativo.', 16, 1);
        RETURN;
    END

    /* ========================================================
       Se houver solicitação, validar e reaproveitar dados dela
       ======================================================== */

    IF @BenefitRequestId IS NOT NULL
    BEGIN
        SELECT
            @RequestBenefitId = benefit_id,
            @RequestPartnerId = partner_id,
            @RequestStatus = request_status,
            @RequestExpiresAt = expires_at,

            @RequestRequesterType = requester_type,
            @RequestRequesterUserId = requester_user_id,
            @RequestRequesterClientId = requester_client_id,
            @RequestRequesterPartnerCustomerId = requester_partner_customer_id,

            @RequestPetSourceType = pet_source_type,
            @RequestClientPetId = requester_client_pet_id,
            @RequestPartnerCustomerPetId = requester_partner_customer_pet_id
        FROM dbo.benefit_requests
        WHERE id = @BenefitRequestId;

        IF @RequestBenefitId IS NULL
        BEGIN
            RAISERROR('Solicitação de benefício não encontrada.', 16, 1);
            RETURN;
        END

        IF @RequestBenefitId <> @BenefitId
        BEGIN
            RAISERROR('A solicitação informada não pertence ao benefício informado.', 16, 1);
            RETURN;
        END

        IF @RequestPartnerId <> @PartnerId
        BEGIN
            RAISERROR('A solicitação informada não pertence ao parceiro do benefício.', 16, 1);
            RETURN;
        END

        IF @RequestExpiresAt IS NOT NULL AND @RequestExpiresAt < @Now
        BEGIN
            RAISERROR('A solicitação de benefício está expirada.', 16, 1);
            RETURN;
        END

        IF @RequestStatus IN (
            'pending_review',
            'under_review'
        )
        BEGIN
            RAISERROR('A solicitação ainda está em análise e não pode ser marcada como utilizada.', 16, 1);
            RETURN;
        END

        IF @RequestStatus IN (
            'declined',
            'cancelled',
            'expired',
            'no_show',
            'converted_to_usage'
        )
        BEGIN
            RAISERROR('A solicitação não pode ser marcada como utilizada no status atual.', 16, 1);
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM dbo.benefit_usages
            WHERE benefit_request_id = @BenefitRequestId
              AND usage_status IN ('confirmed', 'used')
        )
        BEGIN
            RAISERROR('Esta solicitação já possui uma utilização confirmada.', 16, 1);
            RETURN;
        END

        SET @UsedByType = COALESCE(@UsedByType, @RequestRequesterType);
        SET @UsedByUserId = COALESCE(@UsedByUserId, @RequestRequesterUserId);
        SET @UsedByClientId = COALESCE(@UsedByClientId, @RequestRequesterClientId);
        SET @UsedByPartnerCustomerId = COALESCE(@UsedByPartnerCustomerId, @RequestRequesterPartnerCustomerId);

        SET @PetSourceType = COALESCE(@PetSourceType, @RequestPetSourceType);
        SET @ClientPetId = COALESCE(@ClientPetId, @RequestClientPetId);
        SET @PartnerCustomerPetId = COALESCE(@PartnerCustomerPetId, @RequestPartnerCustomerPetId);
    END

    /* ========================================================
       Validações finais do beneficiário e pet
       ======================================================== */

    IF @UsedByType NOT IN ('client', 'partner_customer')
    BEGIN
        RAISERROR('UsedByType inválido.', 16, 1);
        RETURN;
    END

    IF @UsedByType = 'client'
       AND @UsedByClientId IS NULL
       AND @UsedByUserId IS NULL
    BEGIN
        RAISERROR('Uso de cliente exige UsedByClientId ou UsedByUserId.', 16, 1);
        RETURN;
    END

    IF @UsedByType = 'partner_customer'
       AND @UsedByPartnerCustomerId IS NULL
    BEGIN
        RAISERROR('Uso de cliente parceiro exige UsedByPartnerCustomerId.', 16, 1);
        RETURN;
    END

    IF @PetSourceType IS NOT NULL
       AND @PetSourceType NOT IN ('client_pet', 'partner_customer_pet')
    BEGIN
        RAISERROR('PetSourceType inválido.', 16, 1);
        RETURN;
    END

    IF @PetSourceType = 'client_pet'
       AND @ClientPetId IS NULL
    BEGIN
        RAISERROR('PetSourceType client_pet exige ClientPetId.', 16, 1);
        RETURN;
    END

    IF @PetSourceType = 'partner_customer_pet'
       AND @PartnerCustomerPetId IS NULL
    BEGIN
        RAISERROR('PetSourceType partner_customer_pet exige PartnerCustomerPetId.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.benefit_usages
        (
            id,
            benefit_request_id,
            benefit_id,
            partner_id,

            used_by_user_id,
            used_by_client_id,
            used_by_partner_customer_id,
            used_by_type,

            pet_source_type,
            client_pet_id,
            partner_customer_pet_id,

            usage_status,
            used_at,

            recorded_by_user_id,
            confirmed_by_partner_user_id,
            confirmed_by_admin_user_id,

            monetary_value,
            discount_value,

            snapshot_title,
            snapshot_partner_name,
            snapshot_rule_summary,

            created_at,
            updated_at
        )
        VALUES
        (
            @BenefitUsageId,
            @BenefitRequestId,
            @BenefitId,
            @PartnerId,

            @UsedByUserId,
            @UsedByClientId,
            @UsedByPartnerCustomerId,
            @UsedByType,

            @PetSourceType,
            @ClientPetId,
            @PartnerCustomerPetId,

            'used',
            @Now,

            @RecordedByUserId,
            @ConfirmedByPartnerUserId,
            @ConfirmedByAdminUserId,

            @MonetaryValue,
            @DiscountValue,

            @Title,
            @PartnerName,
            @RuleSummary,

            @Now,
            @Now
        );

        IF @BenefitRequestId IS NOT NULL
        BEGIN
            UPDATE dbo.benefit_requests
            SET
                request_status = 'converted_to_usage',
                updated_at = @Now
            WHERE id = @BenefitRequestId;

			EXEC dbo.usp_benefit_request_timeline_event_add
				@BenefitRequestId = @BenefitRequestId,
				@EventType = 'usage_confirmed',
				@EventStatus = 'converted_to_usage',
				@EventPoint = NULL,
				@EventDescription = 'Benefício marcado como utilizado.',
				@ActorUserId = @RecordedByUserId,
				@OccurredAt = @Now;

			EXEC dbo.usp_benefit_request_notification_enqueue
				@BenefitRequestId = @BenefitRequestId,
				@EventType = 'benefits.usage.registered',
				@ReviewPoint = NULL,
				@ReviewRecommendation = NULL,
				@EventReferenceId = @BenefitUsageId;
        END

        UPDATE dbo.benefit_metrics_snapshot
        SET
            usages_count = usages_count + 1,
            conversion_rate =
                CASE
                    WHEN requests_count > 0
                        THEN CAST(((usages_count + 1) * 100.0) / requests_count AS DECIMAL(9,2))
                    ELSE 0
                END,
            refreshed_at = @Now
        WHERE benefit_id = @BenefitId;

        IF @@ROWCOUNT = 0
        BEGIN
            INSERT INTO dbo.benefit_metrics_snapshot
            (
                benefit_id,
                requests_count,
                approved_requests_count,
                usages_count,
                conversion_rate,
                refreshed_at
            )
            SELECT
                @BenefitId,
                (SELECT COUNT(1)
                 FROM dbo.benefit_requests
                 WHERE benefit_id = @BenefitId) AS requests_count,

                (SELECT COUNT(1)
                 FROM dbo.benefit_requests
                 WHERE benefit_id = @BenefitId
                   AND request_status = 'approved') AS approved_requests_count,

                (SELECT COUNT(1)
                 FROM dbo.benefit_usages
                 WHERE benefit_id = @BenefitId
                   AND usage_status IN ('confirmed', 'used')) AS usages_count,

                CASE
                    WHEN (SELECT COUNT(1)
                          FROM dbo.benefit_requests
                          WHERE benefit_id = @BenefitId) > 0
                    THEN
                        CAST(
                            (
                                (SELECT COUNT(1)
                                 FROM dbo.benefit_usages
                                 WHERE benefit_id = @BenefitId
                                   AND usage_status IN ('confirmed', 'used')) * 100.0
                            )
                            /
                            (SELECT COUNT(1)
                             FROM dbo.benefit_requests
                             WHERE benefit_id = @BenefitId)
                        AS DECIMAL(9,2))
                    ELSE 0
                END AS conversion_rate,

                @Now;
        END

        COMMIT TRANSACTION;

        SELECT
            @BenefitUsageId AS benefit_usage_id,
            @BenefitRequestId AS benefit_request_id,
            @BenefitId AS benefit_id,
            @UsedByType AS used_by_type,
            'used' AS usage_status,
            @Now AS used_at;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO

