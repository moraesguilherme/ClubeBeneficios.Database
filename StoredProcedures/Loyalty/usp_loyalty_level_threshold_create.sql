CREATE   PROCEDURE [dbo].[usp_loyalty_level_threshold_create]
    @LevelThresholdId uniqueidentifier,
    @LevelCode varchar(30),
    @LevelName varchar(80),
    @MinAverageTicketAmount decimal(18,2),
    @MaxAverageTicketAmount decimal(18,2) = NULL,
    @EvaluationWindowMonths int = 12,
    @DowngradeGraceMonths int = 1,
    @DisplayOrder int = 0,
    @Status varchar(30) = 'active',
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.loyalty_level_thresholds
    (
        id,
        level_code,
        level_name,
        min_average_ticket_amount,
        max_average_ticket_amount,
        evaluation_window_months,
        downgrade_grace_months,
        display_order,
        status,
        created_at,
        updated_at,
        created_by_user_id
    )
    VALUES
    (
        @LevelThresholdId,
        @LevelCode,
        @LevelName,
        @MinAverageTicketAmount,
        @MaxAverageTicketAmount,
        @EvaluationWindowMonths,
        @DowngradeGraceMonths,
        @DisplayOrder,
        @Status,
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        @CreatedByUserId
    );

    EXEC dbo.usp_loyalty_level_threshold_admin_get
        @LevelThresholdId = @LevelThresholdId;
END;
GO

