CREATE   PROCEDURE [dbo].[usp_loyalty_campaign_condition_update]
    @ConditionId uniqueidentifier,
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

    UPDATE dbo.loyalty_campaign_conditions
    SET
        condition_type = @ConditionType,
        service_type = @ServiceType,
        payment_method = @PaymentMethod,
        target_level_code = @TargetLevelCode,
        bonus_points = @BonusPoints,
        multiplier_value = @MultiplierValue,
        json_payload = @JsonPayload
    WHERE id = @ConditionId;

    SELECT *
    FROM dbo.loyalty_campaign_conditions
    WHERE id = @ConditionId;
END
GO


