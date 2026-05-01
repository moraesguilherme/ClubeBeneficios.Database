CREATE   PROCEDURE [dbo].[usp_loyalty_operational_maintenance_run]
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.usp_loyalty_operational_sync_scheduled_entities;
    EXEC dbo.usp_loyalty_redemptions_expire_due;
    EXEC dbo.usp_loyalty_points_expire_due;
    EXEC dbo.usp_loyalty_score_rebuild_batch;
    EXEC dbo.usp_loyalty_reclassify_batch_by_latest_score
        @CreatedByUserId = @CreatedByUserId;

    SELECT
        completed_at = SYSUTCDATETIME(),
        status = 'ok';
END
GO

