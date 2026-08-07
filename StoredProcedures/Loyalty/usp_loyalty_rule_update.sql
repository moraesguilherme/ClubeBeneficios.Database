CREATE   PROCEDURE [dbo].[usp_loyalty_rule_update]
    @RuleId uniqueidentifier,
    @Name varchar(150),
    @Category varchar(50),
    @Description varchar(1500) = NULL,
    @CalculationType varchar(50),
    @StackingMode varchar(30),
    @Priority int = 0,
    @ValidFrom datetime2(7) = NULL,
    @ValidTo datetime2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.loyalty_rules
    SET
        name = @Name,
        category = @Category,
        description = @Description,
        calculation_type = @CalculationType,
        stacking_mode = @StackingMode,
        priority = @Priority,
        valid_from = @ValidFrom,
        valid_to = @ValidTo,
        updated_at = SYSUTCDATETIME()
    WHERE id = @RuleId;

    SELECT *
    FROM dbo.loyalty_rules
    WHERE id = @RuleId;
END
GO

