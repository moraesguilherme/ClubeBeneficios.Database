CREATE   PROCEDURE [dbo].[usp_loyalty_rule_admin_get]
    @RuleId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.id,
        r.rule_set_id,
        rs.name AS rule_set_name,
        r.name,
        r.category,
        r.description,
        r.calculation_type,
        r.stacking_mode,
        r.status,
        r.priority,
        r.valid_from,
        r.valid_to,
        r.created_at,
        r.updated_at
    FROM dbo.loyalty_rules r
    INNER JOIN dbo.loyalty_rule_sets rs
        ON rs.id = r.rule_set_id
    WHERE r.id = @RuleId;
END
GO

