CREATE   PROCEDURE [dbo].[usp_loyalty_level_threshold_set_status]
    @LevelThresholdId uniqueidentifier,
    @Status varchar(30),
    @UpdatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.loyalty_level_thresholds
    SET
        status = @Status,
        updated_at = SYSUTCDATETIME(),
        updated_by_user_id = @UpdatedByUserId
    WHERE id = @LevelThresholdId;

    EXEC dbo.usp_loyalty_level_threshold_admin_get
        @LevelThresholdId = @LevelThresholdId;
END;
GO

