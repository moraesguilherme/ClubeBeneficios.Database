CREATE   PROCEDURE [dbo].[usp_loyalty_rule_create]
    @RuleId uniqueidentifier,
    @RuleSetId uniqueidentifier,
    @Name varchar(150),
    @Category varchar(50),
    @Description varchar(1500) = NULL,
    @CalculationType varchar(50),
    @StackingMode varchar(30),
    @Status varchar(30),
    @Priority int = 0,
    @ValidFrom datetime2(7) = NULL,
    @ValidTo datetime2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.loyalty_rules
    (
        id,
        rule_set_id,
        name,
        category,
        description,
        calculation_type,
        stacking_mode,
        status,
        priority,
        valid_from,
        valid_to,
        created_at,
        updated_at
    )
    VALUES
    (
        @RuleId,
        @RuleSetId,
        @Name,
        @Category,
        @Description,
        @CalculationType,
        @StackingMode,
        @Status,
        @Priority,
        @ValidFrom,
        @ValidTo,
        SYSUTCDATETIME(),
        SYSUTCDATETIME()
    );

    SELECT *
    FROM dbo.loyalty_rules
    WHERE id = @RuleId;
END
GO


