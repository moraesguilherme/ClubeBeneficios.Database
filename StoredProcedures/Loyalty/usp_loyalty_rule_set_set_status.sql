CREATE   PROCEDURE [dbo].[usp_loyalty_rule_set_set_status]
    @RuleSetId uniqueidentifier,
    @Status varchar(30),
    @UpdatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.loyalty_rule_sets
    SET
        status = @Status,
        updated_at = SYSUTCDATETIME(),
        updated_by_user_id = @UpdatedByUserId
    WHERE id = @RuleSetId;

    SELECT *
    FROM dbo.loyalty_rule_sets
    WHERE id = @RuleSetId;
END
GO


