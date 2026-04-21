CREATE   PROCEDURE [dbo].[usp_loyalty_level_benefits_admin_search]
    @Search varchar(150) = NULL,
    @LevelCode varchar(30) = NULL,
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
            lb.id,
            lb.level_code,
            lb.title,
            lb.description,
            lb.display_order,
            lb.status,
            lb.valid_from,
            lb.valid_to,
            lb.created_at,
            lb.updated_at
        FROM dbo.loyalty_level_benefits lb
        WHERE (@Search IS NULL OR LTRIM(RTRIM(@Search)) = '' OR lb.title LIKE '%' + @Search + '%' OR lb.description LIKE '%' + @Search + '%')
          AND (@LevelCode IS NULL OR @LevelCode = '' OR lb.level_code = @LevelCode)
          AND (@Status IS NULL OR @Status = '' OR lb.status = @Status)
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY level_code ASC, display_order ASC, updated_at DESC)
        FROM Filtered
    )
    SELECT
        id,
        level_code,
        title,
        description,
        display_order,
        status,
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


