CREATE   PROCEDURE [dbo].[usp_loyalty_rewards_catalog_list]
    @Search varchar(150) = NULL,
    @Status varchar(30) = NULL,
    @LevelCode varchar(30) = NULL,
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
            r.title,
            r.description,
            r.points_cost,
            r.availability_summary,
            r.operational_rule_summary,
            r.eligible_level_code,
            r.status,
            r.redemption_mode,
            r.minimum_notice_hours,
            r.cumulative_mode,
            r.usage_window_type,
            r.usage_window_value,
            r.availability_type,
            r.season_type,
            r.is_transferable,
            r.created_at,
            r.updated_at
        FROM dbo.loyalty_rewards r
        WHERE (@Search IS NULL OR LTRIM(RTRIM(@Search)) = '' OR r.title LIKE '%' + @Search + '%' OR r.description LIKE '%' + @Search + '%')
          AND (@Status IS NULL OR @Status = '' OR r.status = @Status)
          AND (@LevelCode IS NULL OR @LevelCode = '' OR r.eligible_level_code = @LevelCode)
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY updated_at DESC, title ASC)
        FROM Filtered
    )
    SELECT
        id,
        title,
        description,
        points_cost,
        availability_summary,
        operational_rule_summary,
        eligible_level_code,
        status,
        redemption_mode,
        minimum_notice_hours,
        cumulative_mode,
        usage_window_type,
        usage_window_value,
        availability_type,
        season_type,
        is_transferable,
        created_at,
        updated_at,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO

