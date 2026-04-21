CREATE   PROCEDURE [dbo].[usp_loyalty_rule_conditions_list]
    @RuleId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        rc.id,
        rc.rule_id,
        rc.condition_type,
        rc.service_type,
        rc.plan_type,
        rc.package_type,
        rc.payment_method,
        rc.target_level_code,
        rc.min_amount,
        rc.max_amount,
        rc.points_value,
        rc.currency_unit_amount,
        rc.multiplier_value,
        rc.window_type,
        rc.window_value,
        rc.json_payload
    FROM dbo.loyalty_rule_conditions rc
    WHERE rc.rule_id = @RuleId
    ORDER BY rc.id;
END
GO


