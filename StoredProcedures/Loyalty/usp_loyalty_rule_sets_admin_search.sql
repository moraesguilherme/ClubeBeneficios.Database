CREATE   PROCEDURE [dbo].[usp_loyalty_rule_sets_admin_search]
    @Search varchar(150) = NULL,
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
            rs.id,
            rs.name,
            rs.description,
            rs.status,
            rs.priority,
            rs.valid_from,
            rs.valid_to,
            rs.created_at,
            rs.updated_at
        FROM dbo.loyalty_rule_sets rs
        WHERE (@Search IS NULL OR LTRIM(RTRIM(@Search)) = '' OR rs.name LIKE '%' + @Search + '%' OR rs.description LIKE '%' + @Search + '%')
          AND (@Status IS NULL OR @Status = '' OR rs.status = @Status)
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
        name,
        description,
        status,
        priority,
        valid_from,
        valid_to,
        created_at,
        updated_at,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO

