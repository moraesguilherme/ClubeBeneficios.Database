CREATE   PROCEDURE [dbo].[usp_loyalty_client_ledger_list]
    @ClientId uniqueidentifier,
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
            e.event_type,
            e.movement_type,
            e.source_type,
            e.source_id,
            e.rule_id,
            e.campaign_id,
            e.reward_id,
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
        WHERE e.client_id = @ClientId
          AND (@EventType IS NULL OR @EventType = '' OR e.event_type = @EventType)
          AND (@MovementType IS NULL OR @MovementType = '' OR e.movement_type = @MovementType)
          AND (@SourceType IS NULL OR @SourceType = '' OR e.source_type = @SourceType)
          AND (@DateFrom IS NULL OR e.occurred_at >= @DateFrom)
          AND (@DateTo IS NULL OR e.occurred_at < @DateTo)
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY occurred_at DESC, created_at DESC)
        FROM Filtered
    )
    SELECT
        id,
        client_id,
        event_type,
        movement_type,
        source_type,
        source_id,
        rule_id,
        campaign_id,
        reward_id,
        adjustment_id,
        points_delta,
        monetary_amount,
        payment_method,
        payment_reference,
        occurred_at,
        effective_at,
        expires_at,
        is_expired,
        description,
        created_at,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO


