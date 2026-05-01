CREATE   PROCEDURE [dbo].[usp_loyalty_reward_create]
    @RewardId uniqueidentifier,
    @Title varchar(150),
    @Description varchar(1500) = NULL,
    @PointsCost int,
    @AvailabilitySummary varchar(300) = NULL,
    @OperationalRuleSummary varchar(1000) = NULL,
    @EligibleLevelCode varchar(30) = NULL,
    @Status varchar(30),
    @RedemptionMode varchar(30) = NULL,
    @MinimumNoticeHours int = NULL,
    @CumulativeMode varchar(30) = NULL,
    @UsageWindowType varchar(30) = NULL,
    @UsageWindowValue int = NULL,
    @AvailabilityType varchar(30) = NULL,
    @SeasonType varchar(30) = NULL,
    @IsTransferable bit = 0,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.loyalty_rewards
    (
        id,
        title,
        description,
        points_cost,
        availability_summary,
        operational_rule_summary,
        eligible_level_code,
        status,
        created_at,
        updated_at,
        created_by_user_id,
        updated_by_user_id,
        redemption_mode,
        minimum_notice_hours,
        cumulative_mode,
        usage_window_type,
        usage_window_value,
        availability_type,
        season_type,
        is_transferable
    )
    VALUES
    (
        @RewardId,
        @Title,
        @Description,
        @PointsCost,
        @AvailabilitySummary,
        @OperationalRuleSummary,
        @EligibleLevelCode,
        @Status,
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        @CreatedByUserId,
        @CreatedByUserId,
        @RedemptionMode,
        @MinimumNoticeHours,
        @CumulativeMode,
        @UsageWindowType,
        @UsageWindowValue,
        @AvailabilityType,
        @SeasonType,
        @IsTransferable
    );

    SELECT *
    FROM dbo.loyalty_rewards
    WHERE id = @RewardId;
END
GO

