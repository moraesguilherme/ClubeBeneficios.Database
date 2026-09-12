CREATE   PROCEDURE [dbo].[usp_public_partner_catalog_get_by_slug]
    @Slug VARCHAR(140)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PartnerId UNIQUEIDENTIFIER;

    SELECT TOP 1
        @PartnerId = pcl.partner_id
    FROM dbo.partner_public_catalog_links pcl
    INNER JOIN dbo.partners p
        ON p.id = pcl.partner_id
    WHERE pcl.slug = @Slug
      AND pcl.status = 'active'
      AND p.status = 'active';

    IF @PartnerId IS NULL
    BEGIN
        SELECT
            CAST(NULL AS UNIQUEIDENTIFIER) AS Id,
            CAST(NULL AS UNIQUEIDENTIFIER) AS PartnerId,
            CAST(NULL AS VARCHAR(150)) AS PartnerName,
            CAST(NULL AS VARCHAR(500)) AS PartnerLogoUrl,
            CAST(NULL AS VARCHAR(120)) AS PartnerSegment,
            CAST(NULL AS VARCHAR(120)) AS PartnerCategory,
            CAST(NULL AS VARCHAR(180)) AS PartnerServiceRegion,
            CAST(NULL AS VARCHAR(140)) AS Slug,
            CAST(NULL AS VARCHAR(180)) AS Title,
            CAST(NULL AS VARCHAR(500)) AS Description,
            CAST(NULL AS VARCHAR(30)) AS Status,
            CAST(0 AS BIT) AS Found;

        SELECT TOP 0
            b.id AS Id,
            b.partner_id AS PartnerId,
            p.trade_name AS PartnerName,
            b.title AS Title,
            b.benefit_type AS BenefitType,
            b.direction AS Direction,
            b.target_actor_type AS TargetActorType,
            b.short_description AS ShortDescription,
            b.full_description AS FullDescription,
            b.eligibility_type AS EligibilityType,
            b.recurrence_type AS RecurrenceType,
            b.recurrence_value AS RecurrenceValue,
            b.recurrence_period AS RecurrencePeriod,
            b.validity_type AS ValidityType,
            b.starts_at AS StartsAt,
            b.ends_at AS EndsAt,
            b.requires_manual_release AS RequiresManualRelease,
            b.requires_active_access_code AS RequiresActiveAccessCode,
            b.requires_matilha_acceptance_rules AS RequiresMatilhaAcceptanceRules,
            b.stacking_rule AS StackingRule,
            b.created_at AS CreatedAt,
            b.updated_at AS UpdatedAt
        FROM dbo.benefits b
        INNER JOIN dbo.partners p
            ON p.id = b.partner_id
        WHERE 1 = 0;

        RETURN;
    END

    SELECT TOP 1
        pcl.id AS Id,
        pcl.partner_id AS PartnerId,
        p.trade_name AS PartnerName,
        p.logo_url AS PartnerLogoUrl,
        p.segment AS PartnerSegment,
        p.category AS PartnerCategory,
        p.service_region AS PartnerServiceRegion,
        pcl.slug AS Slug,
        pcl.title AS Title,
        pcl.description AS Description,
        pcl.status AS Status,
        CAST(1 AS BIT) AS Found
    FROM dbo.partner_public_catalog_links pcl
    INNER JOIN dbo.partners p
        ON p.id = pcl.partner_id
    WHERE pcl.partner_id = @PartnerId
      AND pcl.slug = @Slug
      AND pcl.status = 'active'
      AND p.status = 'active';

    SELECT
        b.id AS Id,
        b.partner_id AS PartnerId,
        p.trade_name AS PartnerName,
        b.title AS Title,
        b.benefit_type AS BenefitType,
        b.direction AS Direction,
        b.target_actor_type AS TargetActorType,
        b.short_description AS ShortDescription,
        b.full_description AS FullDescription,
        b.eligibility_type AS EligibilityType,
        b.recurrence_type AS RecurrenceType,
        b.recurrence_value AS RecurrenceValue,
        b.recurrence_period AS RecurrencePeriod,
        b.validity_type AS ValidityType,
        b.starts_at AS StartsAt,
        b.ends_at AS EndsAt,
        b.requires_manual_release AS RequiresManualRelease,
        b.requires_active_access_code AS RequiresActiveAccessCode,
        b.requires_matilha_acceptance_rules AS RequiresMatilhaAcceptanceRules,
        b.stacking_rule AS StackingRule,
        b.created_at AS CreatedAt,
        b.updated_at AS UpdatedAt
    FROM dbo.benefits b
    INNER JOIN dbo.partners p
        ON p.id = b.partner_id
    WHERE b.partner_id = @PartnerId
      AND b.direction = 'matilha_to_partner'
      AND b.target_actor_type = 'partner_customer'
      AND b.status = 'active'
      AND (
            b.validity_type <> 'date_range'
            OR (
                (b.starts_at IS NULL OR b.starts_at <= SYSUTCDATETIME())
                AND
                (b.ends_at IS NULL OR b.ends_at >= SYSUTCDATETIME())
            )
          )
    ORDER BY
        b.highlight_in_showcase DESC,
        b.created_at DESC;
END
GO

