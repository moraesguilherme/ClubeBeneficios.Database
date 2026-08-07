CREATE   PROCEDURE [dbo].[usp_loyalty_reward_set_status]
    @RewardId uniqueidentifier,
    @Status varchar(30),
    @UpdatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.loyalty_rewards
    SET
        status = @Status,
        updated_at = SYSUTCDATETIME(),
        updated_by_user_id = @UpdatedByUserId
    WHERE id = @RewardId;

    SELECT *
    FROM dbo.loyalty_rewards
    WHERE id = @RewardId;
END
GO

