CREATE   PROCEDURE [dbo].[usp_loyalty_client_balance_validate]
    @ClientId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @LedgerBalance int,
        @StoredBalance int;

    SELECT
        @LedgerBalance =
            ISNULL(SUM(CASE
                WHEN is_expired = 0 THEN points_delta
                ELSE 0
            END), 0)
    FROM dbo.customer_loyalty_events
    WHERE client_id = @ClientId;

    SELECT
        @StoredBalance = ISNULL(available_points, 0)
    FROM dbo.customer_loyalty_balances
    WHERE client_id = @ClientId;

    SELECT
        ledger_balance = @LedgerBalance,
        stored_balance = @StoredBalance,
        is_consistent =
            CASE WHEN @LedgerBalance = @StoredBalance THEN 1 ELSE 0 END;
END
GO


