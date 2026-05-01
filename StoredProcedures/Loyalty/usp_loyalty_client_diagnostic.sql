CREATE   PROCEDURE [dbo].[usp_loyalty_client_diagnostic]
    @ClientId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.id,
        c.full_name
    FROM dbo.clients c
    WHERE c.id = @ClientId;

    SELECT
        *
    FROM dbo.customer_loyalty_balances
    WHERE client_id = @ClientId;

    SELECT TOP 1 *
    FROM dbo.loyalty_score_snapshots
    WHERE client_id = @ClientId
    ORDER BY calculated_at DESC;

    SELECT TOP 1 *
    FROM dbo.loyalty_level_history
    WHERE client_id = @ClientId
    ORDER BY changed_at DESC;

    SELECT
        total_events = COUNT(1),
        total_credit = SUM(CASE WHEN points_delta > 0 THEN points_delta ELSE 0 END),
        total_debit = SUM(CASE WHEN points_delta < 0 THEN points_delta ELSE 0 END)
    FROM dbo.customer_loyalty_events
    WHERE client_id = @ClientId;
END
GO

