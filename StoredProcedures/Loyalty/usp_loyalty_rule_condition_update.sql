CREATE   PROCEDURE [dbo].[usp_loyalty_rule_condition_update]
    @ConditionId uniqueidentifier,
    @ConditionType varchar(50),
    @SourceType varchar(50) = NULL,
    @ServiceType varchar(50) = NULL,
    @PlanType varchar(100) = NULL,
    @PackageType varchar(100) = NULL,
    @PaymentMethod varchar(50) = NULL,
    @TargetLevelCode varchar(30) = NULL,
    @MinAmount decimal(18,2) = NULL,
    @MaxAmount decimal(18,2) = NULL,
    @PointsValue decimal(18,4) = NULL,
    @CurrencyUnitAmount decimal(18,4) = NULL,
    @MultiplierValue decimal(18,4) = NULL,
    @WindowType varchar(30) = NULL,
    @WindowValue int = NULL,
    @JsonPayload nvarchar(max) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.loyalty_rule_conditions
    SET
        condition_type = @ConditionType,
        source_type = @SourceType,
        service_type = @ServiceType,
        plan_type = @PlanType,
        package_type = @PackageType,
        payment_method = @PaymentMethod,
        target_level_code = @TargetLevelCode,
        min_amount = @MinAmount,
        max_amount = @MaxAmount,
        points_value = @PointsValue,
        currency_unit_amount = @CurrencyUnitAmount,
        multiplier_value = @MultiplierValue,
        window_type = @WindowType,
        window_value = @WindowValue,
        json_payload = @JsonPayload
    WHERE id = @ConditionId;

    SELECT *
    FROM dbo.loyalty_rule_conditions
    WHERE id = @ConditionId;
END;
GO

