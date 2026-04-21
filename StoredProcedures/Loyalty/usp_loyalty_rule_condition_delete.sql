CREATE   PROCEDURE [dbo].[usp_loyalty_rule_condition_delete]
    @ConditionId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.loyalty_rule_conditions
    WHERE id = @ConditionId;

    SELECT CAST(1 AS bit) AS success;
END
GO


