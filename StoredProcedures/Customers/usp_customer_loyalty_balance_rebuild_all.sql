CREATE PROCEDURE [dbo].[usp_customer_loyalty_balance_rebuild_all]
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH clients_with_events AS
    (
        SELECT DISTINCT client_id
        FROM dbo.customer_loyalty_events
    )
    SELECT client_id
    INTO #clients_to_rebuild
    FROM clients_with_events;

    DECLARE @ClientId uniqueidentifier;

    DECLARE rebuild_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT client_id
        FROM #clients_to_rebuild;

    OPEN rebuild_cursor;
    FETCH NEXT FROM rebuild_cursor INTO @ClientId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.usp_customer_loyalty_balance_rebuild
            @ClientId = @ClientId;

        FETCH NEXT FROM rebuild_cursor INTO @ClientId;
    END

    CLOSE rebuild_cursor;
    DEALLOCATE rebuild_cursor;

    DROP TABLE #clients_to_rebuild;

    SELECT *
    FROM dbo.customer_loyalty_balances;
END

GO

