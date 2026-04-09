CREATE   PROCEDURE [dbo].[usp_benefit_usages_confirm]
    @BenefitId UNIQUEIDENTIFIER,
    @BenefitRequestId UNIQUEIDENTIFIER = NULL,
    @UsedByType VARCHAR(30),
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

    DECLARE @PartnerId UNIQUEIDENTIFIER;
    DECLARE @Title VARCHAR(180);
    DECLARE @PartnerName VARCHAR(150);

    SELECT
        @PartnerId = b.partner_id,
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

    IF @UsedByType NOT IN ('client', 'partner_customer')
    BEGIN
        RAISERROR('UsedByType inválido.', 16, 1);
        RETURN;
    END

    IF @UsedByType = 'client' AND @UsedByClientId IS NULL AND @UsedByUserId IS NULL
    BEGIN
        RAISERROR('Uso de cliente exige UsedByClientId ou UsedByUserId.', 16, 1);
        RETURN;
    END

    IF @UsedByType = 'partner_customer' AND @UsedByPartnerCustomerId IS NULL
    BEGIN
        RAISERROR('Uso de cliente parceiro exige UsedByPartnerCustomerId.', 16, 1);
        RETURN;
    END

    IF @PetSourceType IS NOT NULL AND @PetSourceType NOT IN ('client_pet', 'partner_customer_pet')
    BEGIN
        RAISERROR('PetSourceType inválido.', 16, 1);
        RETURN;
    END

    IF @PetSourceType = 'client_pet' AND @ClientPetId IS NULL
    BEGIN
        RAISERROR('PetSourceType client_pet exige ClientPetId.', 16, 1);
        RETURN;
    END

    IF @PetSourceType = 'partner_customer_pet' AND @PartnerCustomerPetId IS NULL
    BEGIN
        RAISERROR('PetSourceType partner_customer_pet exige PartnerCustomerPetId.', 16, 1);
        RETURN;
    END

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
        NEWID(),
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
        SYSUTCDATETIME(),
        @RecordedByUserId,
        @ConfirmedByPartnerUserId,
        @ConfirmedByAdminUserId,
        @MonetaryValue,
        @DiscountValue,
        @Title,
        @PartnerName,
        @RuleSummary,
        SYSUTCDATETIME(),
        SYSUTCDATETIME()
    );

    IF @BenefitRequestId IS NOT NULL
    BEGIN
        UPDATE dbo.benefit_requests
        SET
            request_status = 'converted_to_usage',
            updated_at = SYSUTCDATETIME()
        WHERE id = @BenefitRequestId;
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
        refreshed_at = SYSUTCDATETIME()
    WHERE benefit_id = @BenefitId;
END
GO


