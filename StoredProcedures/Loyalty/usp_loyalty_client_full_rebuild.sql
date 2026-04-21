CREATE   PROCEDURE [dbo].[usp_loyalty_client_full_rebuild]
    @ClientId uniqueidentifier,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.usp_customer_loyalty_balance_rebuild
        @ClientId = @ClientId;

    EXEC dbo.usp_loyalty_score_rebuild_by_client
        @ClientId = @ClientId;

    EXEC dbo.usp_loyalty_reclassify_client_by_latest_score
        @ClientId = @ClientId,
        @CreatedByUserId = @CreatedByUserId;

    SELECT
        status = 'rebuild_completed',
        rebuilt_at = SYSUTCDATETIME();
END
GO


