IF COL_LENGTH('dbo.partner_customers', 'public_catalog_link_id') IS NULL
BEGIN
    ALTER TABLE dbo.partner_customers
    ADD public_catalog_link_id UNIQUEIDENTIFIER NULL;
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_partner_customers_public_catalog_links'
)
BEGIN
    ALTER TABLE dbo.partner_customers
    ADD CONSTRAINT FK_partner_customers_public_catalog_links
    FOREIGN KEY (public_catalog_link_id)
    REFERENCES dbo.partner_public_catalog_links(id);
END
GO

IF COL_LENGTH('dbo.benefit_requests', 'public_catalog_link_id') IS NULL
BEGIN
    ALTER TABLE dbo.benefit_requests
    ADD public_catalog_link_id UNIQUEIDENTIFIER NULL;
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_benefit_requests_public_catalog_links'
)
BEGIN
    ALTER TABLE dbo.benefit_requests
    ADD CONSTRAINT FK_benefit_requests_public_catalog_links
    FOREIGN KEY (public_catalog_link_id)
    REFERENCES dbo.partner_public_catalog_links(id);
END
GO