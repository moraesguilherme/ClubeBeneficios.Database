CREATE   PROCEDURE [dbo].[usp_client_account_invitation_complete]
    @TokenHash VARCHAR(128),
    @Name VARCHAR(150),
    @Email VARCHAR(150),
    @Phone VARCHAR(30) = NULL,
    @PasswordHash VARCHAR(500),
    @TermsAccepted BIT,
    @TermsKey VARCHAR(80),
    @TermsVersion VARCHAR(40),
    @IpAddress VARCHAR(45) = NULL,
    @UserAgent VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @Now DATETIME2 = SYSUTCDATETIME(),
        @InvitationId UNIQUEIDENTIFIER,
        @ClientId UNIQUEIDENTIFIER,
        @UserId UNIQUEIDENTIFIER,
        @RoleId UNIQUEIDENTIFIER,
        @InvitationStatus VARCHAR(30),
        @InvitationEmail VARCHAR(150),
        @ExpiresAt DATETIME2,
        @ExistingUserId UNIQUEIDENTIFIER;

    SELECT TOP 1
        @InvitationId = id,
        @ClientId = client_id,
        @UserId = user_id,
        @InvitationStatus = status,
        @InvitationEmail = email,
        @ExpiresAt = expires_at
    FROM dbo.client_account_invitations
    WHERE token_hash = @TokenHash;

    IF @InvitationId IS NULL
    BEGIN
        THROW 51300, 'Convite de ativação não encontrado.', 1;
    END;

    IF @InvitationStatus <> 'pending'
    BEGIN
        THROW 51301, 'Convite de ativação não está mais disponível.', 1;
    END;

    IF @ExpiresAt < @Now
    BEGIN
        UPDATE dbo.client_account_invitations
        SET
            status = 'expired',
            updated_at = @Now
        WHERE id = @InvitationId;

        THROW 51302, 'Convite de ativação expirado.', 1;
    END;

    IF @TermsAccepted <> 1
    BEGIN
        THROW 51303, 'É necessário aceitar os termos para ativar a conta.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@TermsKey)), '') IS NULL
       OR NULLIF(LTRIM(RTRIM(@TermsVersion)), '') IS NULL
    BEGIN
        THROW 51304, 'Dados do termo de aceite inválidos.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@PasswordHash)), '') IS NULL
    BEGIN
        THROW 51305, 'Hash de senha inválido.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
    BEGIN
        THROW 51306, 'Informe o nome do cliente.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@Email)), '') IS NULL
    BEGIN
        THROW 51307, 'Informe o e-mail do cliente.', 1;
    END;

    IF LOWER(LTRIM(RTRIM(@Email))) <> LOWER(LTRIM(RTRIM(@InvitationEmail)))
    BEGIN
        THROW 51308, 'O e-mail informado precisa ser o mesmo do convite.', 1;
    END;

    SELECT
        @RoleId = id
    FROM dbo.roles
    WHERE name = 'client';

    IF @RoleId IS NULL
    BEGIN
        THROW 51309, 'Role client não encontrada.', 1;
    END;

    SELECT TOP 1
        @ExistingUserId = id
    FROM dbo.users
    WHERE LOWER(LTRIM(RTRIM(email))) = LOWER(LTRIM(RTRIM(@Email)));

    IF @ExistingUserId IS NOT NULL
    BEGIN
        THROW 51310, 'Já existe uma conta cadastrada com este e-mail.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.clients
        WHERE id = @ClientId
          AND user_id IS NOT NULL
    )
    BEGIN
        THROW 51311, 'Este cliente já possui acesso criado.', 1;
    END;

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
        NULL,
        LTRIM(RTRIM(@Name)),
        LOWER(LTRIM(RTRIM(@Email))),
        @PasswordHash,
        NULLIF(LTRIM(RTRIM(@Phone)), ''),
        'active',
        'client',
        1,
        NULL,
        @Now,
        @Now
    );

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

    UPDATE dbo.clients
    SET
        user_id = @UserId,
        full_name = LTRIM(RTRIM(@Name)),
        email = LOWER(LTRIM(RTRIM(@Email))),
        phone = NULLIF(LTRIM(RTRIM(@Phone)), ''),
        status = CASE 
            WHEN status IN ('inactive', 'pending_activation') THEN 'active'
            ELSE status
        END,
        lgpd_consent_at = @Now,
        updated_at = @Now
    WHERE id = @ClientId;

    UPDATE dbo.client_account_invitations
    SET
        user_id = @UserId,
        status = 'accepted',
        accepted_at = @Now,
        updated_at = @Now
    WHERE id = @InvitationId;

    INSERT INTO dbo.client_terms_acceptances
    (
        id,
        client_id,
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
        @ClientId,
        @UserId,
        @InvitationId,
        LTRIM(RTRIM(@TermsKey)),
        LTRIM(RTRIM(@TermsVersion)),
        @Now,
        NULLIF(LTRIM(RTRIM(@IpAddress)), ''),
        NULLIF(LTRIM(RTRIM(@UserAgent)), '')
    );

    SELECT
        i.id AS Id,
        i.client_id AS ClientId,
        i.user_id AS UserId,
        i.email AS Email,
        i.status AS Status,
        i.accepted_at AS AcceptedAt,

        c.full_name AS ClientName,
        c.status AS ClientStatus,

        u.name AS UserName,
        u.email AS UserEmail,
        u.status AS UserStatus,
        u.email_confirmed AS EmailConfirmed
    FROM dbo.client_account_invitations i
    INNER JOIN dbo.clients c
        ON c.id = i.client_id
    INNER JOIN dbo.users u
        ON u.id = i.user_id
    WHERE i.id = @InvitationId;
END;
GO

