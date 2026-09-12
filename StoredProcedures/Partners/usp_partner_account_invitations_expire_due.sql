CREATE   PROCEDURE [dbo].[usp_partner_account_invitations_expire_due]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now datetime2 = SYSUTCDATETIME();

    UPDATE dbo.partner_account_invitations
    SET
        status = 'expired',
        updated_at = @Now
    WHERE status = 'pending'
      AND expires_at < @Now;

    SELECT @@ROWCOUNT AS expired_count;
END;
GO

