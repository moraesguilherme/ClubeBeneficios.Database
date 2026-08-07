CREATE   PROCEDURE [dbo].[usp_loyalty_rule_set_admin_get]
    @RuleSetId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        rs.id,
        rs.name,
        rs.description,
        rs.status,
        rs.priority,
        rs.valid_from,
        rs.valid_to,
        rs.created_at,
        rs.updated_at,
        rs.created_by_user_id,
        rs.updated_by_user_id,
        total_rules =
        (
            SELECT COUNT(1)
            FROM dbo.loyalty_rules r
            WHERE r.rule_set_id = rs.id
        ),
        active_rules =
        (
            SELECT COUNT(1)
            FROM dbo.loyalty_rules r
            WHERE r.rule_set_id = rs.id
              AND r.status = 'active'
        )
    FROM dbo.loyalty_rule_sets rs
    WHERE rs.id = @RuleSetId;
END
GO

