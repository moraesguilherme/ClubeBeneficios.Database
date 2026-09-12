CREATE   PROCEDURE [dbo].[usp_partner_public_catalog_link_get_by_slug]
    @Slug VARCHAR(140)
AS
BEGIN
    SET NOCOUNT ON;

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
        pcl.created_at AS CreatedAt,
        pcl.updated_at AS UpdatedAt
    FROM dbo.partner_public_catalog_links pcl
    INNER JOIN dbo.partners p
        ON p.id = pcl.partner_id
    WHERE pcl.slug = @Slug
      AND pcl.status = 'active'
      AND p.status = 'active';
END
GO

