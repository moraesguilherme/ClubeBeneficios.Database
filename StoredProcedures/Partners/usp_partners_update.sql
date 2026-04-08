CREATE PROCEDURE dbo.usp_partners_update
    @PartnerId                UNIQUEIDENTIFIER,
    @TradeName                VARCHAR(150) = NULL,
    @LegalName                VARCHAR(150) = NULL,
    @Document                 VARCHAR(30) = NULL,
    @Email                    VARCHAR(150) = NULL,
    @Phone                    VARCHAR(30) = NULL,
    @LogoUrl                  VARCHAR(500) = NULL,
    @Segment                  VARCHAR(120) = NULL,
    @Category                 VARCHAR(120) = NULL,
    @ServiceRegion            VARCHAR(180) = NULL,
    @Website                  VARCHAR(250) = NULL,
    @Instagram                VARCHAR(150) = NULL,
    @Description              VARCHAR(1200) = NULL,
    @Level                    VARCHAR(30) = NULL,
    @ResponsibleName          VARCHAR(180) = NULL,
    @ResponsibleRole          VARCHAR(120) = NULL,
    @ResponsibleEmail         VARCHAR(150) = NULL,
    @ResponsiblePhone         VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.partners
       SET trade_name = @TradeName,
           legal_name = @LegalName,
           document = @Document,
           email = @Email,
           phone = @Phone,
           logo_url = @LogoUrl,
           segment = @Segment,
           category = @Category,
           service_region = @ServiceRegion,
           website = @Website,
           instagram = @Instagram,
           description = @Description,
           level = @Level,
           updated_at = SYSUTCDATETIME()
     WHERE id = @PartnerId;

    IF EXISTS (
        SELECT 1
        FROM dbo.partner_contacts
        WHERE partner_id = @PartnerId
          AND is_primary = 1
    )
    BEGIN
        UPDATE dbo.partner_contacts
           SET name = ISNULL(NULLIF(LTRIM(RTRIM(@ResponsibleName)), ''), name),
               role_name = @ResponsibleRole,
               email = @ResponsibleEmail,
               phone = @ResponsiblePhone,
               is_active = 1,
               updated_at = SYSUTCDATETIME()
         WHERE partner_id = @PartnerId
           AND is_primary = 1;
    END
    ELSE IF COALESCE(@ResponsibleName, @ResponsibleRole, @ResponsibleEmail, @ResponsiblePhone) IS NOT NULL
    BEGIN
        INSERT INTO dbo.partner_contacts
        (
            id,
            partner_id,
            name,
            role_name,
            email,
            phone,
            is_primary,
            is_active,
            created_at,
            updated_at
        )
        VALUES
        (
            NEWID(),
            @PartnerId,
            ISNULL(NULLIF(LTRIM(RTRIM(@ResponsibleName)), ''), @TradeName),
            @ResponsibleRole,
            @ResponsibleEmail,
            @ResponsiblePhone,
            1,
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END
END
GO