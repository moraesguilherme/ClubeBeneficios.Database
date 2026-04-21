CREATE   PROCEDURE [dbo].[usp_loyalty_client_balance_get]
    @ClientId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        b.client_id,
        b.available_points,
        b.pending_points,
        b.expired_points,
		b.redeemed_points,
        b.lifetime_earned_points,
        b.last_movement_at,
        b.updated_at
    FROM dbo.customer_loyalty_balances b
    WHERE b.client_id = @ClientId;
END
GO


