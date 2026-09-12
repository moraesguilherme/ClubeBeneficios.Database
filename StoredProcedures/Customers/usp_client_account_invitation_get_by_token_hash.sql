CREATE   PROCEDURE [dbo].[usp_client_account_invitation_get_by_token_hash]
    @TokenHash VARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now DATETIME2 = SYSUTCDATETIME();

    UPDATE dbo.client_account_invitations
    SET
        status = 'expired',
        updated_at = @Now
    WHERE token_hash = @TokenHash
      AND status = 'pending'
      AND expires_at < @Now;

    SELECT TOP 1
        i.id AS Id,
        i.client_id AS ClientId,
        i.user_id AS UserId,
        i.email AS Email,
        i.token_hash AS TokenHash,
        i.status AS Status,
        i.expires_at AS ExpiresAt,
        i.accepted_at AS AcceptedAt,
        i.created_at AS CreatedAt,

        c.full_name AS ClientName,
        c.document AS ClientDocument,
        c.email AS ClientEmail,
        c.phone AS ClientPhone,
        c.birth_date AS ClientBirthDate,
        c.status AS ClientStatus,

        CAST(CASE
            WHEN i.status = 'pending' AND i.expires_at >= @Now THEN 1
            ELSE 0
        END AS BIT) AS CanComplete
    FROM dbo.client_account_invitations i
    INNER JOIN dbo.clients c
        ON c.id = i.client_id
    WHERE i.token_hash = @TokenHash;
END;
GO

