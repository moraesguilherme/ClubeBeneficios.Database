CREATE   PROCEDURE [dbo].[usp_loyalty_campaign_admin_get]
    @CampaignId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.id,
        c.name,
        c.description,
        c.campaign_type,
        c.status,
        c.starts_at,
        c.ends_at,
        c.audience_type,
        c.stacking_mode,
        c.created_at,
        c.updated_at
    FROM dbo.loyalty_campaigns c
    WHERE c.id = @CampaignId;
END
GO


