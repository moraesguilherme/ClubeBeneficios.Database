CREATE   PROCEDURE [dbo].[usp_client_account_invitation_create]
    @ClientId UNIQUEIDENTIFIER,
    @CreatedByUserId UNIQUEIDENTIFIER = NULL,
    @TokenHash VARCHAR(128),
    @ExpiresAt DATETIME2
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @Now DATETIME2 = SYSUTCDATETIME(),
        @ClientStatus VARCHAR(30),
        @ClientName VARCHAR(150),
        @ClientEmail VARCHAR(150),
        @InvitationId UNIQUEIDENTIFIER,
        @ExistingUserId UNIQUEIDENTIFIER;

    SELECT
        @ClientStatus = c.status,
        @ClientName = c.full_name,
        @ClientEmail = c.email,
        @ExistingUserId = c.user_id
    FROM dbo.clients c
    WHERE c.id = @ClientId;

    IF @ClientStatus IS NULL
    BEGIN
        THROW 51200, 'Cliente não encontrado.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@ClientEmail)), '') IS NULL
    BEGIN
        THROW 51201, 'O cliente não possui e-mail cadastrado.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@TokenHash)), '') IS NULL
    BEGIN
        THROW 51202, 'Hash do token inválido.', 1;
    END;

    IF @ExpiresAt <= @Now
    BEGIN
        THROW 51203, 'A data de expiração do convite precisa ser futura.', 1;
    END;

    IF @ExistingUserId IS NOT NULL
    BEGIN
        THROW 51204, 'Este cliente já possui acesso criado.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.users u
        WHERE LOWER(LTRIM(RTRIM(u.email))) = LOWER(LTRIM(RTRIM(@ClientEmail)))
    )
    BEGIN
        THROW 51205, 'Já existe uma conta cadastrada com este e-mail.', 1;
    END;

    UPDATE dbo.client_account_invitations
    SET
        status = 'cancelled',
        cancelled_at = @Now,
        updated_at = @Now
    WHERE client_id = @ClientId
      AND status = 'pending';

    SET @InvitationId = NEWID();

    INSERT INTO dbo.client_account_invitations
    (
        id,
        client_id,
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
        @ClientId,
        NULL,
        LOWER(LTRIM(RTRIM(@ClientEmail))),
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
        i.client_id AS ClientId,
        i.user_id AS UserId,
        i.email AS Email,
        i.token_hash AS TokenHash,
        i.status AS Status,
        i.expires_at AS ExpiresAt,
        i.created_at AS CreatedAt,
        c.full_name AS ClientName,
        c.phone AS ClientPhone
    FROM dbo.client_account_invitations i
    INNER JOIN dbo.clients c
        ON c.id = i.client_id
    WHERE i.id = @InvitationId;
END;
GO

