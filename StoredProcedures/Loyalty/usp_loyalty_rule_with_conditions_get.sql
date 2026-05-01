CREATE   PROCEDURE [dbo].[usp_loyalty_rule_with_conditions_get]
    @RuleId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.usp_loyalty_rule_admin_get
        @RuleId = @RuleId;

    EXEC dbo.usp_loyalty_rule_conditions_list
        @RuleId = @RuleId;
END
GO

