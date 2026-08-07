CREATE   PROCEDURE [dbo].[usp_loyalty_client_redemptions_list]
    @ClientId uniqueidentifier,
    @Status varchar(30) = NULL,
    @PageNumber int = 1,
    @PageSize int = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 20;

    ;WITH Numbered AS
    (
        SELECT
            r.id,
            r.client_id,
            r.reward_id,
            rw.title AS reward_title,
            r.redemption_code,
            r.requested_points_cost,
            r.approved_points_cost,
            r.status,
            r.request_channel,
            r.requested_at,
            r.approved_at,
            r.rejected_at,
            r.canceled_at,
            r.used_at,
            r.completed_at,
            r.expires_at,
            r.notes,
            r.internal_notes,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY r.requested_at DESC)
        FROM dbo.loyalty_redemptions r
        INNER JOIN dbo.loyalty_rewards rw
            ON rw.id = r.reward_id
        WHERE r.client_id = @ClientId
          AND (@Status IS NULL OR @Status = '' OR r.status = @Status)
    )
    SELECT
        id,
        client_id,
        reward_id,
        reward_title,
        redemption_code,
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

