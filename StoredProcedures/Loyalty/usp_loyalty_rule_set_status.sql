CREATE   PROCEDURE [dbo].[usp_loyalty_rule_set_status]
    @RuleId uniqueidentifier,
    @Status varchar(30)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.loyalty_rules
    SET
        status = @Status,
        updated_at = SYSUTCDATETIME()
    WHERE id = @RuleId;

    SELECT *
    FROM dbo.loyalty_rules
    WHERE id = @RuleId;
END
GO


