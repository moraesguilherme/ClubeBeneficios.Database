CREATE   PROCEDURE [dbo].[usp_loyalty_redemptions_queue_list]
    @Search varchar(150) = NULL,
    @Status varchar(30) = NULL,
    @DateFrom datetime2(7) = NULL,
    @DateTo datetime2(7) = NULL,
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
            rr.id,
            rr.client_id,
            c.full_name AS client_name,
            rr.reward_id,
            r.title AS reward_title,
            rr.requested_points_cost,
            rr.approved_points_cost,
            rr.status,
            rr.request_channel,
            rr.requested_at,
            rr.approved_at,
            rr.rejected_at,
            rr.canceled_at,
            rr.used_at,
            rr.completed_at,
            rr.expires_at,
            rr.notes,
            rr.internal_notes
        FROM dbo.loyalty_redemptions rr
        INNER JOIN dbo.clients c
            ON c.id = rr.client_id
        INNER JOIN dbo.loyalty_rewards r
            ON r.id = rr.reward_id
        WHERE (@Search IS NULL OR LTRIM(RTRIM(@Search)) = '' OR c.full_name LIKE '%' + @Search + '%' OR r.title LIKE '%' + @Search + '%')
          AND (@Status IS NULL OR @Status = '' OR rr.status = @Status)
          AND (@DateFrom IS NULL OR rr.requested_at >= @DateFrom)
          AND (@DateTo IS NULL OR rr.requested_at < @DateTo)
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY requested_at DESC)
        FROM Filtered
    )
    SELECT
        id,
        client_id,
        client_name,
        reward_id,
        reward_title,
        requested_points_cost,
        approved_points_cost,
        status,
        request_channel,
        requested_at,
        approved_at,
        rejected_at,
        canceled_at,
        used_at,
        completed_at,
        expires_at,
        notes,
        internal_notes,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO

