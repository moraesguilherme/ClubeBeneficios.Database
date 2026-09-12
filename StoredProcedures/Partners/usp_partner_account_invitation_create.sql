CREATE   PROCEDURE [dbo].[usp_partner_account_invitation_create]
    @PartnerId uniqueidentifier,
    @CreatedByUserId uniqueidentifier = NULL,
    @TokenHash varchar(128),
    @ExpiresAt datetime2
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @Now datetime2 = SYSUTCDATETIME(),
        @PartnerStatus varchar(30),
        @PartnerName varchar(150),
        @ResponsibleName varchar(150),
        @ResponsibleRole varchar(100),
        @ResponsibleEmail varchar(150),
        @ResponsiblePhone varchar(30),
        @InvitationId uniqueidentifier;

    SELECT
        @PartnerStatus = p.status,
        @PartnerName = p.trade_name,
        @ResponsibleName = pc.name,
        @ResponsibleRole = pc.role_name,
        @ResponsibleEmail = pc.email,
        @ResponsiblePhone = pc.phone
    FROM dbo.partners p
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
    WHERE p.id = @PartnerId;

    IF @PartnerStatus IS NULL
    BEGIN
        THROW 51000, 'Parceiro não encontrado.', 1;
    END;

    IF @PartnerStatus <> 'approved'
    BEGIN
        THROW 51001, 'O parceiro precisa estar aprovado antes da geração do convite.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@ResponsibleEmail)), '') IS NULL
    BEGIN
        THROW 51002, 'O parceiro aprovado não possui e-mail de responsável cadastrado.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@TokenHash)), '') IS NULL
    BEGIN
        THROW 51003, 'Hash do token inválido.', 1;
    END;

    IF @ExpiresAt <= @Now
    BEGIN
        THROW 51004, 'A data de expiração do convite precisa ser futura.', 1;
    END;

    UPDATE dbo.partner_account_invitations
    SET
        status = 'cancelled',
        cancelled_at = @Now,
        updated_at = @Now
    WHERE partner_id = @PartnerId
      AND status = 'pending';

    SET @InvitationId = NEWID();

    INSERT INTO dbo.partner_account_invitations
    (
        id,
        partner_id,
        user_id,
        email,
        token_hash,
        status,
        expires_at,
        accepted_at,
        cancelled_at,
        created_by_user_id,
        created_at,
        updated_at
    )
    VALUES
    (
        @InvitationId,
        @PartnerId,
        NULL,
        LTRIM(RTRIM(@ResponsibleEmail)),
        @TokenHash,
        'pending',
        @ExpiresAt,
        NULL,
        NULL,
        @CreatedByUserId,
        @Now,
        @Now
    );

    SELECT
		i.id AS Id,
		i.partner_id AS PartnerId,
		i.user_id AS UserId,
		i.email AS Email,
		i.token_hash AS TokenHash,
		i.status AS Status,
		i.expires_at AS ExpiresAt,
		i.created_at AS CreatedAt,
		p.trade_name AS PartnerName,
		@ResponsibleName AS ResponsibleName,
		@ResponsibleRole AS ResponsibleRole,
		@ResponsiblePhone AS ResponsiblePhone
	FROM dbo.partner_account_invitations i
	INNER JOIN dbo.partners p
		ON p.id = i.partner_id
	WHERE i.id = @InvitationId;
END;
GO

