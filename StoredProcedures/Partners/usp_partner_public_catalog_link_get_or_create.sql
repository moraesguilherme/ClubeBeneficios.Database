CREATE   PROCEDURE [dbo].[usp_partner_public_catalog_link_get_or_create]
    @PartnerId UNIQUEIDENTIFIER,
    @CreatedByUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @ExistingId UNIQUEIDENTIFIER,
        @Slug VARCHAR(140),
        @PartnerName VARCHAR(150),
        @Now DATETIME2(7) = SYSUTCDATETIME();

    SELECT TOP 1
        @ExistingId = pcl.id
    FROM dbo.partner_public_catalog_links pcl
    WHERE pcl.partner_id = @PartnerId
      AND pcl.status = 'active'
    ORDER BY pcl.created_at DESC;

    IF @ExistingId IS NOT NULL
    BEGIN
        SELECT
            pcl.id AS Id,
            pcl.partner_id AS PartnerId,
            p.trade_name AS PartnerName,
            pcl.slug AS Slug,
            pcl.title AS Title,
            pcl.description AS Description,
            pcl.status AS Status,
            pcl.created_by_user_id AS CreatedByUserId,
            pcl.created_at AS CreatedAt,
            pcl.updated_at AS UpdatedAt
        FROM dbo.partner_public_catalog_links pcl
        INNER JOIN dbo.partners p
            ON p.id = pcl.partner_id
        WHERE pcl.id = @ExistingId;

        RETURN;
    END

    SELECT
        @PartnerName = p.trade_name
    FROM dbo.partners p
    WHERE p.id = @PartnerId;

    IF @PartnerName IS NULL
    BEGIN
        RAISERROR('Parceiro não encontrado.', 16, 1);
        RETURN;
    END

    SET @Slug = CONCAT(
        'p-',
        LEFT(REPLACE(CONVERT(VARCHAR(36), @PartnerId), '-', ''), 12)
    );

    WHILE EXISTS
    (
        SELECT 1
        FROM dbo.partner_public_catalog_links
        WHERE slug = @Slug
    )
    BEGIN
        SET @Slug = CONCAT(
            'p-',
            LEFT(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 12)
        );
    END

    INSERT INTO dbo.partner_public_catalog_links
    (
        id,
        partner_id,
        slug,
        title,
        description,
        status,
        created_by_user_id,
        created_at,
        updated_at
    )
    VALUES
    (
        NEWID(),
        @PartnerId,
        @Slug,
        CONCAT('Benefícios Matilha - ', @PartnerName),
        'Link público para clientes do parceiro acessarem os benefícios disponíveis.',
        'active',
        @CreatedByUserId,
        @Now,
        @Now
    );

    SELECT
        pcl.id AS Id,
        pcl.partner_id AS PartnerId,
        p.trade_name AS PartnerName,
        pcl.slug AS Slug,
        pcl.title AS Title,
        pcl.description AS Description,
        pcl.status AS Status,
        pcl.created_by_user_id AS CreatedByUserId,
        pcl.created_at AS CreatedAt,
        pcl.updated_at AS UpdatedAt
    FROM dbo.partner_public_catalog_links pcl
    INNER JOIN dbo.partners p
        ON p.id = pcl.partner_id
    WHERE pcl.partner_id = @PartnerId
      AND pcl.slug = @Slug;
END
GO

