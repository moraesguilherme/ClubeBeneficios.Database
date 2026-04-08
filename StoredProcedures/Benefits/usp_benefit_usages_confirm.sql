CREATE PROCEDURE dbo.usp_benefit_usages_confirm
    @BenefitId UNIQUEIDENTIFIER,
    @BenefitRequestId UNIQUEIDENTIFIER = NULL,
    @UsedByType VARCHAR(30),
    @UsedByUserId UNIQUEIDENTIFIER = NULL,
    @UsedByPartnerCustomerId UNIQUEIDENTIFIER = NULL,
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
    INNER JOIN dbo.partners p ON p.id = b.partner_id
    WHERE b.id = @BenefitId;

    IF @PartnerId IS NULL
    BEGIN
        RAISERROR('BenefÃ­cio nÃ£o encontrado.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.benefit_usages
    (
        id, benefit_request_id, benefit_id, partner_id,
        used_by_user_id, used_by_partner_customer_id, used_by_type,
        usage_status, used_at, confirmed_by_partner_user_id, confirmed_by_admin_user_id,
        monetary_value, discount_value, snapshot_title, snapshot_partner_name, snapshot_rule_summary,
        created_at, updated_at
    )
    VALUES
    (
        NEWID(), @BenefitRequestId, @BenefitId, @PartnerId,
        @UsedByUserId, @UsedByPartnerCustomerId, @UsedByType,
        'used', SYSUTCDATETIME(), @ConfirmedByPartnerUserId, @ConfirmedByAdminUserId,
        @MonetaryValue, @DiscountValue, @Title, @PartnerName, @RuleSummary,
        SYSUTCDATETIME(), SYSUTCDATETIME()
    );

    UPDATE dbo.benefit_metrics_snapshot
    SET
        usages_count = usages_count + 1,
        conversion_rate = CASE WHEN requests_count > 0 THEN CAST(((usages_count + 1) * 100.0) / requests_count AS DECIMAL(9,2)) ELSE 0 END,
        refreshed_at = SYSUTCDATETIME()
    WHERE benefit_id = @BenefitId;
END
GO