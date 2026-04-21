CREATE   PROCEDURE [dbo].[usp_loyalty_redemptions_expire_due]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now datetime2(7) = SYSUTCDATETIME();

    UPDATE dbo.loyalty_redemptions
    SET
        status = 'expired',
        updated_at = @Now
    WHERE status = 'approved'
      AND expires_at IS NOT NULL
      AND expires_at <= @Now;

    SELECT @@ROWCOUNT AS expired_redemptions;
END
GO


