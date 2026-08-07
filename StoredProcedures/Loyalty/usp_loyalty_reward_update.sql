CREATE   PROCEDURE [dbo].[usp_loyalty_reward_update]
    @RewardId uniqueidentifier,
    @Title varchar(150),
    @Description varchar(1500) = NULL,
    @PointsCost int,
    @AvailabilitySummary varchar(300) = NULL,
    @OperationalRuleSummary varchar(1000) = NULL,
    @EligibleLevelCode varchar(30) = NULL,
    @RedemptionMode varchar(30) = NULL,
    @MinimumNoticeHours int = NULL,
    @CumulativeMode varchar(30) = NULL,
    @UsageWindowType varchar(30) = NULL,
    @UsageWindowValue int = NULL,
    @AvailabilityType varchar(30) = NULL,
    @SeasonType varchar(30) = NULL,
    @IsTransferable bit = 0,
    @UpdatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.loyalty_rewards
    SET
        title = @Title,
        description = @Description,
        points_cost = @PointsCost,
        availability_summary = @AvailabilitySummary,
        operational_rule_summary = @OperationalRuleSummary,
        eligible_level_code = @EligibleLevelCode,
        redemption_mode = @RedemptionMode,
        minimum_notice_hours = @MinimumNoticeHours,
        cumulative_mode = @CumulativeMode,
        usage_window_type = @UsageWindowType,
        usage_window_value = @UsageWindowValue,
        availability_type = @AvailabilityType,
        season_type = @SeasonType,
        is_transferable = @IsTransferable,
        updated_at = SYSUTCDATETIME(),
        updated_by_user_id = @UpdatedByUserId
    WHERE id = @RewardId;

    SELECT *
    FROM dbo.loyalty_rewards
    WHERE id = @RewardId;
END
GO

