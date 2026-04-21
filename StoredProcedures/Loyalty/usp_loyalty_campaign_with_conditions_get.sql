CREATE   PROCEDURE [dbo].[usp_loyalty_campaign_with_conditions_get]
    @CampaignId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.usp_loyalty_campaign_admin_get
        @CampaignId = @CampaignId;

    EXEC dbo.usp_loyalty_campaign_conditions_list
        @CampaignId = @CampaignId;
END
GO


