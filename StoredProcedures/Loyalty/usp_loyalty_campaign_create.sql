CREATE   PROCEDURE [dbo].[usp_loyalty_campaign_create]
    @CampaignId uniqueidentifier,
    @Name varchar(150),
    @Description varchar(1500) = NULL,
    @CampaignType varchar(50),
    @Status varchar(30),
    @StartsAt datetime2(7),
    @EndsAt datetime2(7) = NULL,
    @AudienceType varchar(50) = NULL,
    @StackingMode varchar(30)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.loyalty_campaigns
    (
        id,
        name,
        description,
        campaign_type,
        status,
        starts_at,
        ends_at,
        audience_type,
        stacking_mode,
        created_at,
        updated_at
    )
    VALUES
    (
        @CampaignId,
        @Name,
        @Description,
        @CampaignType,
        @Status,
        @StartsAt,
        @EndsAt,
        @AudienceType,
        @StackingMode,
        SYSUTCDATETIME(),
        SYSUTCDATETIME()
    );

    SELECT *
    FROM dbo.loyalty_campaigns
    WHERE id = @CampaignId;
END
GO


