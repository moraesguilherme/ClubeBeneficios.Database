CREATE   PROCEDURE [dbo].[usp_loyalty_client_metrics_history_list]
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
            s.level_code,
            s.trend_code,
            s.trend_reason,
            s.average_ticket_amount,
            s.available_points,
            s.pending_points,
            s.upgrade_distance_amount,
            s.downgrade_risk_flag,
            s.low_redemption_flag,
            s.calculated_at,
            s.created_at,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY s.calculated_at DESC, s.created_at DESC)
        FROM dbo.customer_loyalty_metric_snapshots s
        WHERE s.client_id = @ClientId
    )
    SELECT *
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO

