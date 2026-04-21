CREATE   PROCEDURE [dbo].[usp_loyalty_rule_set_update]
    @RuleSetId uniqueidentifier,
    @Name varchar(150),
    @Description varchar(1000) = NULL,
    @Priority int = 0,
    @ValidFrom datetime2(7) = NULL,
    @ValidTo datetime2(7) = NULL,
    @UpdatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.loyalty_rule_sets
    SET
        name = @Name,
        description = @Description,
        priority = @Priority,
        valid_from = @ValidFrom,
        valid_to = @ValidTo,
        updated_at = SYSUTCDATETIME(),
        updated_by_user_id = @UpdatedByUserId
    WHERE id = @RuleSetId;

    SELECT *
    FROM dbo.loyalty_rule_sets
    WHERE id = @RuleSetId;
END
GO


