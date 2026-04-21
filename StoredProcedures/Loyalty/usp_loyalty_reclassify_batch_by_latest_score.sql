CREATE   PROCEDURE [dbo].[usp_loyalty_reclassify_batch_by_latest_score]
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ClientId uniqueidentifier;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT DISTINCT s.client_id
        FROM dbo.loyalty_score_snapshots s;

    OPEN cur;
    FETCH NEXT FROM cur INTO @ClientId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.usp_loyalty_reclassify_client_by_latest_score
            @ClientId = @ClientId,
            @CreatedByUserId = @CreatedByUserId;

        FETCH NEXT FROM cur INTO @ClientId;
    END

    CLOSE cur;
    DEALLOCATE cur;

    SELECT COUNT(DISTINCT s.client_id) AS processed_clients
    FROM dbo.loyalty_score_snapshots s;
END
GO


