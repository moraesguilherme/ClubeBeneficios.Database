CREATE   PROCEDURE [dbo].[usp_loyalty_events_admin_search]
    @Search varchar(150) = NULL,
    @ClientId uniqueidentifier = NULL,
    @EventType varchar(50) = NULL,
    @MovementType varchar(30) = NULL,
    @SourceType varchar(50) = NULL,
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
            e.id,
            e.client_id,
            c.full_name AS client_name,
            e.event_type,
            e.movement_type,
            e.source_type,
            e.source_id,
            e.source_reference,
            e.rule_id,
            r.name AS rule_name,
            e.campaign_id,
            ca.name AS campaign_name,
            e.reward_id,
            rw.title AS reward_title,
            e.adjustment_id,
            e.points_delta,
            e.monetary_amount,
            e.payment_method,
            e.payment_reference,
            e.occurred_at,
            e.effective_at,
            e.expires_at,
            e.is_expired,
            e.description,
            e.created_at
        FROM dbo.customer_loyalty_events e
        INNER JOIN dbo.clients c ON c.id = e.client_id
        LEFT JOIN dbo.loyalty_rules r ON r.id = e.rule_id
        LEFT JOIN dbo.loyalty_campaigns ca ON ca.id = e.campaign_id
        LEFT JOIN dbo.loyalty_rewards rw ON rw.id = e.reward_id
        WHERE (@Search IS NULL OR @Search = ''
                OR c.full_name LIKE '%' + @Search + '%'
                OR e.description LIKE '%' + @Search + '%'
                OR r.name LIKE '%' + @Search + '%'
                OR rw.title LIKE '%' + @Search + '%')
          AND (@ClientId IS NULL OR e.client_id = @ClientId)
          AND (@EventType IS NULL OR @EventType = '' OR e.event_type = @EventType)
          AND (@MovementType IS NULL OR @MovementType = '' OR e.movement_type = @MovementType)
          AND (@SourceType IS NULL OR @SourceType = '' OR e.source_type = @SourceType)
          AND (@DateFrom IS NULL OR e.effective_at >= @DateFrom)
          AND (@DateTo IS NULL OR e.effective_at < @DateTo)
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY effective_at DESC, created_at DESC)
        FROM Filtered
    )
    SELECT *
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END;
GO

