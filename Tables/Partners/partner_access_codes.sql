CREATE TABLE dbo.partner_access_codes
(
    id                  UNIQUEIDENTIFIER   NOT NULL,
    partner_id          UNIQUEIDENTIFIER   NOT NULL,
    created_by_user_id  UNIQUEIDENTIFIER   NOT NULL,
    code                VARCHAR(100)       NOT NULL,
    description         VARCHAR(300)       NULL,
    status              VARCHAR(30)        NOT NULL,
    expires_at          DATETIME2(7)       NULL,
    max_uses            INT                NULL,
    used_count          INT                NOT NULL CONSTRAINT DF_partner_access_codes_used_count DEFAULT ((0)),
    created_at          DATETIME2(7)       NOT NULL,
    updated_at          DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_partner_access_codes PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT UQ_partner_access_codes_code UNIQUE NONCLUSTERED (code ASC),
    CONSTRAINT FK_partner_access_codes_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
    CONSTRAINT FK_partner_access_codes_users FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id),
    CONSTRAINT CK_partner_access_codes_status CHECK ([status] IN ('active', 'inactive', 'expired', 'blocked'))
);
GO

CREATE INDEX IX_partner_access_codes_partner_status
    ON dbo.partner_access_codes(partner_id, status);
GO
