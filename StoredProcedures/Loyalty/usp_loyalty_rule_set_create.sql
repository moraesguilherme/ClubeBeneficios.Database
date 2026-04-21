CREATE   PROCEDURE [dbo].[usp_loyalty_rule_set_create]
    @RuleSetId uniqueidentifier,
    @Name varchar(150),
    @Description varchar(1000) = NULL,
    @Status varchar(30),
    @Priority int = 0,
    @ValidFrom datetime2(7) = NULL,
    @ValidTo datetime2(7) = NULL,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.loyalty_rule_sets
    (
        id,
        name,
        description,
        status,
        priority,
        valid_from,
        valid_to,
        created_at,
        updated_at,
        created_by_user_id,
        updated_by_user_id
    )
    VALUES
    (
        @RuleSetId,
        @Name,
        @Description,
        @Status,
        @Priority,
        @ValidFrom,
        @ValidTo,
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        @CreatedByUserId,
        @CreatedByUserId
    );

    SELECT *
    FROM dbo.loyalty_rule_sets
    WHERE id = @RuleSetId;
END
GO


