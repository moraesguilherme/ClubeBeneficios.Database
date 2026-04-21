CREATE   PROCEDURE [dbo].[usp_loyalty_campaign_conditions_list]
    @CampaignId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        cc.id,
        cc.campaign_id,
        cc.condition_type,
        cc.service_type,
        cc.payment_method,
        cc.target_level_code,
        cc.bonus_points,
        cc.multiplier_value,
        cc.json_payload
    FROM dbo.loyalty_campaign_conditions cc
    WHERE cc.campaign_id = @CampaignId
    ORDER BY cc.id;
END
GO


