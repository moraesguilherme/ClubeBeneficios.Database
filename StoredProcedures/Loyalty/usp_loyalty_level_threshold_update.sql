CREATE   PROCEDURE [dbo].[usp_loyalty_level_threshold_update]
    @LevelThresholdId uniqueidentifier,
    @LevelCode varchar(30),
    @LevelName varchar(80),
    @MinAverageTicketAmount decimal(18,2),
    @MaxAverageTicketAmount decimal(18,2) = NULL,
    @EvaluationWindowMonths int = 12,
    @DowngradeGraceMonths int = 1,
    @DisplayOrder int = 0,
    @UpdatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.loyalty_level_thresholds
    SET
        level_code = @LevelCode,
        level_name = @LevelName,
        min_average_ticket_amount = @MinAverageTicketAmount,
        max_average_ticket_amount = @MaxAverageTicketAmount,
        evaluation_window_months = @EvaluationWindowMonths,
        downgrade_grace_months = @DowngradeGraceMonths,
        display_order = @DisplayOrder,
        updated_at = SYSUTCDATETIME(),
        updated_by_user_id = @UpdatedByUserId
    WHERE id = @LevelThresholdId;

    EXEC dbo.usp_loyalty_level_threshold_admin_get
        @LevelThresholdId = @LevelThresholdId;
END;
GO

