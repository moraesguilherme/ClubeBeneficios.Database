CREATE   PROCEDURE [dbo].[usp_loyalty_campaign_update]
    @CampaignId uniqueidentifier,
    @Name varchar(150),
    @Description varchar(1500) = NULL,
    @CampaignType varchar(50),
    @StartsAt datetime2(7),
    @EndsAt datetime2(7) = NULL,
    @AudienceType varchar(50) = NULL,
    @StackingMode varchar(30)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.loyalty_campaigns
    SET
        name = @Name,
        description = @Description,
        campaign_type = @CampaignType,
        starts_at = @StartsAt,
        ends_at = @EndsAt,
        audience_type = @AudienceType,
        stacking_mode = @StackingMode,
        updated_at = SYSUTCDATETIME()
    WHERE id = @CampaignId;

    SELECT *
    FROM dbo.loyalty_campaigns
    WHERE id = @CampaignId;
END
GO


