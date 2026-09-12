CREATE   PROCEDURE [dbo].[usp_partner_account_invitation_complete]
    @TokenHash varchar(128),
    @Name varchar(150),
    @Email varchar(150),
    @Phone varchar(30) = NULL,
    @PasswordHash varchar(500),
    @TermsAccepted bit,
    @TermsKey varchar(80),
    @TermsVersion varchar(40),
    @IpAddress varchar(45) = NULL,
    @UserAgent varchar(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @Now datetime2 = SYSUTCDATETIME(),
        @InvitationId uniqueidentifier,
        @PartnerId uniqueidentifier,
        @UserId uniqueidentifier,
        @RoleId uniqueidentifier,
        @InvitationStatus varchar(30),
        @InvitationEmail varchar(150),
        @ExpiresAt datetime2,
        @ExistingUserId uniqueidentifier;

    SELECT TOP 1
        @InvitationId = id,
        @PartnerId = partner_id,
        @UserId = user_id,
        @InvitationStatus = status,
        @InvitationEmail = email,
        @ExpiresAt = expires_at
    FROM dbo.partner_account_invitations
    WHERE token_hash = @TokenHash;

    IF @InvitationId IS NULL
    BEGIN
        THROW 51100, 'Convite de ativação não encontrado.', 1;
    END;

    IF @InvitationStatus <> 'pending'
    BEGIN
        THROW 51101, 'Convite de ativação não está mais disponível.', 1;
    END;

    IF @ExpiresAt < @Now
    BEGIN
        UPDATE dbo.partner_account_invitations
        SET
            status = 'expired',
            updated_at = @Now
        WHERE id = @InvitationId;

        THROW 51102, 'Convite de ativação expirado.', 1;
    END;

    IF @TermsAccepted <> 1
    BEGIN
        THROW 51103, 'É necessário aceitar os termos para ativar a conta.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@TermsKey)), '') IS NULL
       OR NULLIF(LTRIM(RTRIM(@TermsVersion)), '') IS NULL
    BEGIN
        THROW 51104, 'Dados do termo de aceite inválidos.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@PasswordHash)), '') IS NULL
    BEGIN
        THROW 51105, 'Hash de senha inválido.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
    BEGIN
        THROW 51106, 'Informe o nome do usuário responsável.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@Email)), '') IS NULL
    BEGIN
        THROW 51107, 'Informe o e-mail do usuário responsável.', 1;
    END;

    SELECT
        @RoleId = id
    FROM dbo.roles
    WHERE name = 'partner';

    IF @RoleId IS NULL
    BEGIN
        THROW 51108, 'Role partner não encontrada.', 1;
    END;

    SELECT TOP 1
        @ExistingUserId = id
    FROM dbo.users
    WHERE email = LTRIM(RTRIM(@Email))
      AND (
            partner_id <> @PartnerId
            OR user_type <> 'partner'
          );

    IF @ExistingUserId IS NOT NULL
    BEGIN
        THROW 51109, 'Já existe outro usuário cadastrado com este e-mail.', 1;
    END;

    SELECT TOP 1
        @UserId = id
    FROM dbo.users
    WHERE partner_id = @PartnerId
      AND user_type = 'partner';

    IF @UserId IS NULL
    BEGIN
        SET @UserId = NEWID();

        INSERT INTO dbo.users
        (
            id,
            partner_id,
            name,
            email,
            password_hash,
            phone,
            status,
            user_type,
            email_confirmed,
            last_login_at,
            created_at,
            updated_at
        )
        VALUES
        (
            @UserId,
            @PartnerId,
            LTRIM(RTRIM(@Name)),
            LTRIM(RTRIM(@Email)),
            @PasswordHash,
            NULLIF(LTRIM(RTRIM(@Phone)), ''),
            'active',
            'partner',
            1,
            NULL,
            @Now,
            @Now
        );
    END
    ELSE
    BEGIN
        UPDATE dbo.users
        SET
            name = LTRIM(RTRIM(@Name)),
            email = LTRIM(RTRIM(@Email)),
            password_hash = @PasswordHash,
            phone = NULLIF(LTRIM(RTRIM(@Phone)), ''),
            status = 'active',
            user_type = 'partner',
            email_confirmed = 1,
            updated_at = @Now
        WHERE id = @UserId;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.user_roles
        WHERE user_id = @UserId
          AND role_id = @RoleId
    )
    BEGIN
        INSERT INTO dbo.user_roles
        (
            id,
            user_id,
            role_id,
            created_at
        )
        VALUES
        (
            NEWID(),
            @UserId,
            @RoleId,
            @Now
        );
    END;

    UPDATE dbo.partner_account_invitations
    SET
        user_id = @UserId,
        status = 'accepted',
        accepted_at = @Now,
        updated_at = @Now
    WHERE id = @InvitationId;

    INSERT INTO dbo.partner_terms_acceptances
    (
        id,
        partner_id,
        user_id,
        invitation_id,
        terms_key,
        terms_version,
        accepted_at,
        ip_address,
        user_agent
    )
    VALUES
    (
        NEWID(),
        @PartnerId,
        @UserId,
        @InvitationId,
        LTRIM(RTRIM(@TermsKey)),
        LTRIM(RTRIM(@TermsVersion)),
        @Now,
        NULLIF(LTRIM(RTRIM(@IpAddress)), ''),
        NULLIF(LTRIM(RTRIM(@UserAgent)), '')
    );

    UPDATE dbo.partners
    SET
        status = 'active',
        updated_at = @Now
    WHERE id = @PartnerId
      AND status = 'approved';

    SELECT
		i.id AS Id,
		i.partner_id AS PartnerId,
		i.user_id AS UserId,
		i.email AS Email,
		i.status AS Status,
		i.accepted_at AS AcceptedAt,
		p.trade_name AS PartnerName,
		p.status AS PartnerStatus,
		u.name AS UserName,
		u.email AS UserEmail,
		u.status AS UserStatus,
		u.email_confirmed AS EmailConfirmed
	FROM dbo.partner_account_invitations i
	INNER JOIN dbo.partners p
		ON p.id = i.partner_id
	INNER JOIN dbo.users u
		ON u.id = i.user_id
	WHERE i.id = @InvitationId;
END;
GO

