CREATE   PROCEDURE [dbo].[usp_loyalty_score_ranking_search]
    @Search varchar(150) = NULL,
    @LevelCode varchar(30) = NULL,
    @TrendCode varchar(30) = NULL,
    @DowngradeRiskOnly bit = 0,
    @SortBy varchar(30) = 'score_desc',
    @PageNumber int = 1,
    @PageSize int = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 20;

    ;WITH LatestScore AS
    (
        SELECT
            s.id,
            s.client_id,
            s.score_value,
            s.level_code,
            s.trend_code,
            s.trend_reason,
            s.average_ticket_amount,
            s.available_points,
            s.pending_points,
            s.upgrade_distance,
            s.downgrade_risk_flag,
            s.low_redemption_flag,
            s.calculated_at,
            ROW_NUMBER() OVER (PARTITION BY s.client_id ORDER BY s.calculated_at DESC, s.created_at DESC) AS rn
        FROM dbo.loyalty_score_snapshots s
    ),
    Filtered AS
    (
        SELECT
            c.id AS client_id,
            c.full_name AS client_name,
            s.score_value,
            s.level_code,
            s.trend_code,
            s.trend_reason,
            s.average_ticket_amount,
            s.available_points,
            s.pending_points,
            s.upgrade_distance,
            s.downgrade_risk_flag,
            s.low_redemption_flag,
            s.calculated_at
        FROM LatestScore s
        INNER JOIN dbo.clients c
            ON c.id = s.client_id
        WHERE s.rn = 1
          AND (@Search IS NULL OR LTRIM(RTRIM(@Search)) = '' OR c.full_name LIKE '%' + @Search + '%')
          AND (@LevelCode IS NULL OR @LevelCode = '' OR s.level_code = @LevelCode)
          AND (@TrendCode IS NULL OR @TrendCode = '' OR s.trend_code = @TrendCode)
          AND (@DowngradeRiskOnly = 0 OR s.downgrade_risk_flag = 1)
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER
            (
                ORDER BY
                    CASE WHEN @SortBy = 'score_asc' THEN score_value END ASC,
                    CASE WHEN @SortBy = 'score_desc' THEN score_value END DESC,
                    CASE WHEN @SortBy = 'name_asc' THEN client_name END ASC,
                    CASE WHEN @SortBy = 'level_desc' THEN
                        CASE level_code
                            WHEN 'diamond' THEN 4
                            WHEN 'gold' THEN 3
                            WHEN 'silver' THEN 2
                            WHEN 'bronze' THEN 1
                            ELSE 0
                        END
                    END DESC,
                    score_value DESC,
                    client_name ASC
            )
        FROM Filtered
    )
    SELECT
        client_id,
        client_name,
        score_value,
        level_code,
        trend_code,
        trend_reason,
        average_ticket_amount,
        available_points,
        pending_points,
        upgrade_distance,
        downgrade_risk_flag,
        low_redemption_flag,
        calculated_at,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO


