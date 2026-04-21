CREATE   PROCEDURE [dbo].[usp_loyalty_reward_admin_get]
    @RewardId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.id,
        r.title,
        r.description,
        r.points_cost,
        r.availability_summary,
        r.operational_rule_summary,
        r.eligible_level_code,
        r.status,
        r.redemption_mode,
        r.minimum_notice_hours,
        r.cumulative_mode,
        r.usage_window_type,
        r.usage_window_value,
        r.availability_type,
        r.season_type,
        r.is_transferable,
        r.created_at,
        r.updated_at,
        r.created_by_user_id,
        r.updated_by_user_id
    FROM dbo.loyalty_rewards r
    WHERE r.id = @RewardId;
END
GO


