CREATE   PROCEDURE [dbo].[usp_loyalty_score_rebuild_batch]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ClientId uniqueidentifier;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT b.client_id
        FROM dbo.customer_loyalty_balances b;

    OPEN cur;
    FETCH NEXT FROM cur INTO @ClientId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.usp_loyalty_score_rebuild_by_client
            @ClientId = @ClientId;

        FETCH NEXT FROM cur INTO @ClientId;
    END

    CLOSE cur;
    DEALLOCATE cur;

    SELECT COUNT(1) AS processed_clients
    FROM dbo.customer_loyalty_balances;
END
GO


