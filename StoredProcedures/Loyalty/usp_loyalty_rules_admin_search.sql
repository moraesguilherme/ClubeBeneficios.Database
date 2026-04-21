CREATE   PROCEDURE [dbo].[usp_loyalty_rules_admin_search]
    @Search varchar(150) = NULL,
    @RuleSetId uniqueidentifier = NULL,
    @Category varchar(50) = NULL,
    @Status varchar(30) = NULL,
    @PageNumber int = 1,
    @PageSize int = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 20;

    ;WITH Filtered AS
    (
        SELECT
            r.id,
            r.rule_set_id,
            rs.name AS rule_set_name,
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
            r.updated_at,
            conditions_count =
            (
                SELECT COUNT(1)
                FROM dbo.loyalty_rule_conditions rc
                WHERE rc.rule_id = r.id
            )
        FROM dbo.loyalty_rules r
        INNER JOIN dbo.loyalty_rule_sets rs
            ON rs.id = r.rule_set_id
        WHERE (@Search IS NULL OR LTRIM(RTRIM(@Search)) = '' OR r.name LIKE '%' + @Search + '%' OR r.description LIKE '%' + @Search + '%')
          AND (@RuleSetId IS NULL OR r.rule_set_id = @RuleSetId)
          AND (@Category IS NULL OR @Category = '' OR r.category = @Category)
          AND (@Status IS NULL OR @Status = '' OR r.status = @Status)
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY priority DESC, updated_at DESC, name ASC)
        FROM Filtered
    )
    SELECT
        id,
        rule_set_id,
        rule_set_name,
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
        updated_at,
        conditions_count,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO


