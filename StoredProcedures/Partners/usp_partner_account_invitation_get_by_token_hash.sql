CREATE   PROCEDURE [dbo].[usp_partner_account_invitation_get_by_token_hash]
    @TokenHash varchar(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now datetime2 = SYSUTCDATETIME();

    UPDATE dbo.partner_account_invitations
    SET
        status = 'expired',
        updated_at = @Now
    WHERE token_hash = @TokenHash
      AND status = 'pending'
      AND expires_at < @Now;

    SELECT TOP 1
		i.id AS Id,
		i.partner_id AS PartnerId,
		i.user_id AS UserId,
		i.email AS Email,
		i.token_hash AS TokenHash,
		i.status AS Status,
		i.expires_at AS ExpiresAt,
		i.accepted_at AS AcceptedAt,
		i.created_at AS CreatedAt,

		p.trade_name AS PartnerName,
		p.legal_name AS PartnerLegalName,
		p.document AS PartnerDocument,
		p.status AS PartnerStatus,

		pc.name AS ResponsibleName,
		pc.role_name AS ResponsibleRole,
		pc.email AS ResponsibleEmail,
		pc.phone AS ResponsiblePhone,

		CAST(CASE
			WHEN i.status = 'pending' AND i.expires_at >= @Now THEN 1
			ELSE 0
		END AS bit) AS CanComplete
	FROM dbo.partner_account_invitations i
	INNER JOIN dbo.partners p
		ON p.id = i.partner_id
	OUTER APPLY
	(
		SELECT TOP 1
			c.name,
			c.role_name,
			c.email,
			c.phone
		FROM dbo.partner_contacts c
		WHERE c.partner_id = p.id
		ORDER BY c.created_at ASC
	) pc
	WHERE i.token_hash = @TokenHash;
END;
GO

