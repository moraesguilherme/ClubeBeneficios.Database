CREATE   PROCEDURE [dbo].[usp_loyalty_client_score_history_list]
    @ClientId uniqueidentifier,
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
            s.created_at,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY s.calculated_at DESC, s.created_at DESC)
        FROM dbo.loyalty_score_snapshots s
        WHERE s.client_id = @ClientId
    )
    SELECT
        id,
        client_id,
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
        created_at,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO


