CREATE   PROCEDURE [dbo].[usp_loyalty_campaign_condition_create]
    @ConditionId uniqueidentifier,
    @CampaignId uniqueidentifier,
    @ConditionType varchar(50),
    @ServiceType varchar(50) = NULL,
    @PaymentMethod varchar(50) = NULL,
    @TargetLevelCode varchar(30) = NULL,
    @BonusPoints int = NULL,
    @MultiplierValue decimal(18,4) = NULL,
    @JsonPayload nvarchar(max) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.loyalty_campaign_conditions
    (
        id,
        campaign_id,
        condition_type,
        service_type,
        payment_method,
        target_level_code,
        bonus_points,
        multiplier_value,
        json_payload
    )
    VALUES
    (
        @ConditionId,
        @CampaignId,
        @ConditionType,
        @ServiceType,
        @PaymentMethod,
        @TargetLevelCode,
        @BonusPoints,
        @MultiplierValue,
        @JsonPayload
    );

    SELECT *
    FROM dbo.loyalty_campaign_conditions
    WHERE id = @ConditionId;
END
GO


