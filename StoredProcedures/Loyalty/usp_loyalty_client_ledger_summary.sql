CREATE   PROCEDURE [dbo].[usp_loyalty_client_ledger_summary]
    @ClientId uniqueidentifier,
    @DateFrom datetime2(7) = NULL,
    @DateTo datetime2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartDate datetime2(7) = ISNULL(@DateFrom, DATEADD(DAY, -90, SYSUTCDATETIME()));
    DECLARE @EndDate datetime2(7) = ISNULL(@DateTo, SYSUTCDATETIME());

    SELECT
        credited_points = ISNULL(SUM(CASE WHEN e.points_delta > 0 THEN e.points_delta ELSE 0 END), 0),
        debited_points = ABS(ISNULL(SUM(CASE WHEN e.points_delta < 0 THEN e.points_delta ELSE 0 END), 0)),
        expired_points = ABS(ISNULL(SUM(CASE WHEN e.is_expired = 1 THEN e.points_delta ELSE 0 END), 0)),
        total_events = COUNT(1),
        last_event_at = MAX(e.occurred_at)
    FROM dbo.customer_loyalty_events e
    WHERE e.client_id = @ClientId
      AND e.occurred_at >= @StartDate
      AND e.occurred_at < @EndDate;
END
GO


