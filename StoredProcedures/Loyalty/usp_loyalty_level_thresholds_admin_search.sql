CREATE   PROCEDURE [dbo].[usp_loyalty_level_thresholds_admin_search]
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
            id,
            level_code,
            level_name,
            min_average_ticket_amount,
            max_average_ticket_amount,
            evaluation_window_months,
            downgrade_grace_months,
            display_order,
            status,
            created_at,
            updated_at
        FROM dbo.loyalty_level_thresholds
        WHERE (@Search IS NULL OR LTRIM(RTRIM(@Search)) = ''
                OR level_code LIKE '%' + @Search + '%'
                OR level_name LIKE '%' + @Search + '%')
          AND (@Status IS NULL OR @Status = '' OR status = @Status)
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY display_order ASC, min_average_ticket_amount ASC)
        FROM Filtered
    )
    SELECT
        id,
        level_code,
        level_name,
        min_average_ticket_amount,
        max_average_ticket_amount,
        evaluation_window_months,
        downgrade_grace_months,
        display_order,
        status,
        created_at,
        updated_at,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END;
GO

