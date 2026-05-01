CREATE   PROCEDURE [dbo].[usp_loyalty_redemption_full_get]
    @RedemptionId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.*,
        c.full_name AS client_name,
        rw.title AS reward_title
    FROM dbo.loyalty_redemptions r
    INNER JOIN dbo.clients c ON c.id = r.client_id
    INNER JOIN dbo.loyalty_rewards rw ON rw.id = r.reward_id
    WHERE r.id = @RedemptionId;
END
GO

