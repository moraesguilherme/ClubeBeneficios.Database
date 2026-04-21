CREATE   PROCEDURE [dbo].[usp_loyalty_points_expire_due]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now datetime2(7) = SYSUTCDATETIME();

    DECLARE @AffectedClients TABLE
    (
        client_id uniqueidentifier PRIMARY KEY
    );

    UPDATE e
    SET
        is_expired = 1
    OUTPUT inserted.client_id INTO @AffectedClients(client_id)
    FROM dbo.customer_loyalty_events e
    WHERE e.is_expired = 0
      AND e.expires_at IS NOT NULL
      AND e.expires_at <= @Now
      AND e.points_delta > 0;

    DECLARE @ClientId uniqueidentifier;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT client_id FROM @AffectedClients;

    OPEN cur;
    FETCH NEXT FROM cur INTO @ClientId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.usp_customer_loyalty_balance_rebuild
            @ClientId = @ClientId;

        FETCH NEXT FROM cur INTO @ClientId;
    END

    CLOSE cur;
    DEALLOCATE cur;

    SELECT COUNT(1) AS affected_clients
    FROM @AffectedClients;
END
GO


