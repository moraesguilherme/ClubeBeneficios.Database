CREATE   PROCEDURE [dbo].[usp_loyalty_rule_condition_create]
    @ConditionId uniqueidentifier,
    @RuleId uniqueidentifier,
    @ConditionType varchar(50),
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

    INSERT INTO dbo.loyalty_rule_conditions
    (
        id,
        rule_id,
        condition_type,
        service_type,
        plan_type,
        package_type,
        payment_method,
        target_level_code,
        min_amount,
        max_amount,
        points_value,
        currency_unit_amount,
        multiplier_value,
        window_type,
        window_value,
        json_payload
    )
    VALUES
    (
        @ConditionId,
        @RuleId,
        @ConditionType,
        @ServiceType,
        @PlanType,
        @PackageType,
        @PaymentMethod,
        @TargetLevelCode,
        @MinAmount,
        @MaxAmount,
        @PointsValue,
        @CurrencyUnitAmount,
        @MultiplierValue,
        @WindowType,
        @WindowValue,
        @JsonPayload
    );

    SELECT *
    FROM dbo.loyalty_rule_conditions
    WHERE id = @ConditionId;
END
GO


