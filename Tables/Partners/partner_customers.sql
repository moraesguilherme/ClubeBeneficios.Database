CREATE TABLE dbo.partner_customers
(
    id                  UNIQUEIDENTIFIER   NOT NULL,
    partner_id          UNIQUEIDENTIFIER   NOT NULL,
    origin_code_id      UNIQUEIDENTIFIER   NULL,
    name                VARCHAR(150)       NULL,
    email               VARCHAR(150)       NULL,
    phone               VARCHAR(30)        NULL,
    status              VARCHAR(30)        NOT NULL,
    created_at          DATETIME2(7)       NOT NULL,
    last_access_at      DATETIME2(7)       NULL,
    updated_at          DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_partner_customers PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT FK_partner_customers_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
    CONSTRAINT FK_partner_customers_codes FOREIGN KEY (origin_code_id) REFERENCES dbo.partner_access_codes(id),
    CONSTRAINT CK_partner_customers_status CHECK ([status] IN ('active', 'inactive', 'blocked'))
);
GO

CREATE INDEX IX_partner_customers_partner_id
    ON dbo.partner_customers(partner_id);
GO

CREATE INDEX IX_partner_customers_origin_code_id
    ON dbo.partner_customers(origin_code_id);
GO
