CREATE   PROCEDURE [dbo].[usp_loyalty_rule_set_with_rules_get]
    @RuleSetId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.usp_loyalty_rule_set_admin_get
        @RuleSetId = @RuleSetId;

    SELECT
        r.id,
        r.rule_set_id,
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
    WHERE r.rule_set_id = @RuleSetId
    ORDER BY r.priority DESC, r.updated_at DESC, r.name ASC;
END
GO

