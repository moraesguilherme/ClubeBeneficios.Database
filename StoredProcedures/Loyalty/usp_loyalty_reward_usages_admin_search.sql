CREATE   PROCEDURE [dbo].[usp_loyalty_reward_usages_admin_search]
    @Search varchar(150) = NULL,
    @Status varchar(30) = NULL,
    @LevelCode varchar(30) = NULL,
    @RewardType varchar(30) = NULL,
    @DateFrom datetime2(7) = NULL,
    @DateTo datetime2(7) = NULL,
    @PageNumber int = 1,
    @PageSize int = 20,
    @Sort varchar(30) = 'date_desc'
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 20;

    SET @Sort = ISNULL(NULLIF(@Sort, ''), 'date_desc');

    IF @Sort NOT IN ('date_desc', 'customer_asc', 'points_desc', 'points_asc')
        SET @Sort = 'date_desc';

    ;WITH LatestLevel AS
    (
        SELECT
            h.client_id,
            h.to_level_code,
            ROW_NUMBER() OVER (
                PARTITION BY h.client_id
                ORDER BY h.changed_at DESC, h.created_at DESC
            ) AS rn
        FROM dbo.loyalty_level_history h
    ),
    Filtered AS
    (
        SELECT
            lr.id AS redemption_id,
            lr.client_id,
            c.full_name AS client_name,
            lr.reward_id,
            rw.title AS reward_title,
            rw.description AS reward_description,
            ISNULL(ll.to_level_code, rw.eligible_level_code) AS level_code,
            lr.requested_points_cost,
            lr.approved_points_cost,
            lr.status,
            lr.request_channel,
            rw.redemption_mode,
            rw.usage_window_type,
            rw.usage_window_value,
            rw.availability_type AS reward_type,
            lr.requested_at,
            lr.approved_at,
            lr.rejected_at,
            lr.canceled_at,
            lr.scheduled_for,
            lr.used_at,
            lr.completed_at,
            lr.expires_at,
            lr.notes,
            lr.internal_notes,
            lr.created_at,
            lr.updated_at
        FROM dbo.loyalty_redemptions lr
        INNER JOIN dbo.clients c
            ON c.id = lr.client_id
        INNER JOIN dbo.loyalty_rewards rw
            ON rw.id = lr.reward_id
        LEFT JOIN LatestLevel ll
            ON ll.client_id = lr.client_id
           AND ll.rn = 1
        WHERE
            (
                @Search IS NULL OR @Search = ''
                OR c.full_name LIKE '%' + @Search + '%'
                OR rw.title LIKE '%' + @Search + '%'
                OR lr.redemption_code LIKE '%' + @Search + '%'
            )
            AND (@Status IS NULL OR @Status = '' OR @Status = 'all' OR lr.status = @Status)
            AND (@LevelCode IS NULL OR @LevelCode = '' OR @LevelCode = 'all' OR ISNULL(ll.to_level_code, rw.eligible_level_code) = @LevelCode)
            AND (@RewardType IS NULL OR @RewardType = '' OR @RewardType = 'all' OR rw.availability_type = @RewardType)
            AND (@DateFrom IS NULL OR lr.requested_at >= @DateFrom)
            AND (@DateTo IS NULL OR lr.requested_at < DATEADD(DAY, 1, @DateTo))
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (
                ORDER BY
                    CASE WHEN @Sort = 'customer_asc' THEN client_name END ASC,
                    CASE WHEN @Sort = 'points_desc' THEN ISNULL(approved_points_cost, requested_points_cost) END DESC,
                    CASE WHEN @Sort = 'points_asc' THEN ISNULL(approved_points_cost, requested_points_cost) END ASC,
                    requested_at DESC,
                    created_at DESC,
                    redemption_id DESC
            )
        FROM Filtered
    )
    SELECT *
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1)
                      AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END;
GO

