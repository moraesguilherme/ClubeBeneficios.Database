CREATE   PROCEDURE [dbo].[usp_loyalty_campaign_set_status]
    @CampaignId uniqueidentifier,
    @Status varchar(30)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.loyalty_campaigns
    SET
        status = @Status,
        updated_at = SYSUTCDATETIME()
    WHERE id = @CampaignId;

    SELECT *
    FROM dbo.loyalty_campaigns
    WHERE id = @CampaignId;
END
GO

