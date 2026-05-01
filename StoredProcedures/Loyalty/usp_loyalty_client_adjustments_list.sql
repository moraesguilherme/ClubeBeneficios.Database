CREATE   PROCEDURE [dbo].[usp_loyalty_client_adjustments_list]
    @ClientId uniqueidentifier,
    @Status varchar(30) = NULL,
    @AdjustmentType varchar(50) = NULL,
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
            a.id,
            a.client_id,
            a.adjustment_type,
            a.impact_type,
            a.points_delta,
            a.target_entity_type,
            a.target_entity_id,
            a.reason,
            a.requested_by_type,
            a.status,
            a.decision_notes,
            a.requested_at,
            a.decided_at,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY a.requested_at DESC)
        FROM dbo.loyalty_adjustments a
        WHERE a.client_id = @ClientId
          AND (@Status IS NULL OR @Status = '' OR a.status = @Status)
          AND (@AdjustmentType IS NULL OR @AdjustmentType = '' OR a.adjustment_type = @AdjustmentType)
    )
    SELECT
        id,
        client_id,
        adjustment_type,
        impact_type,
        points_delta,
        target_entity_type,
        target_entity_id,
        reason,
        requested_by_type,
        status,
        decision_notes,
        requested_at,
        decided_at,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO

