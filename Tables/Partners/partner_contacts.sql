CREATE TABLE dbo.partner_contacts
(
    id              UNIQUEIDENTIFIER   NOT NULL,
    partner_id      UNIQUEIDENTIFIER   NOT NULL,
    name            VARCHAR(180)       NOT NULL,
    role_name       VARCHAR(120)       NULL,
    email           VARCHAR(150)       NULL,
    phone           VARCHAR(30)        NULL,
    is_primary      BIT                NOT NULL CONSTRAINT DF_partner_contacts_is_primary DEFAULT ((0)),
    is_active       BIT                NOT NULL CONSTRAINT DF_partner_contacts_is_active DEFAULT ((1)),
    created_at      DATETIME2(7)       NOT NULL,
    updated_at      DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_partner_contacts PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT FK_partner_contacts_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id)
);
GO

CREATE UNIQUE INDEX UX_partner_contacts_primary
    ON dbo.partner_contacts(partner_id)
    WHERE is_primary = 1;
GO

CREATE INDEX IX_partner_contacts_partner_id
    ON dbo.partner_contacts(partner_id, is_active, is_primary);
GO
