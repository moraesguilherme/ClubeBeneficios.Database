CREATE TABLE dbo.access_code_usages
(
    id                          UNIQUEIDENTIFIER   NOT NULL,
    partner_access_code_id      UNIQUEIDENTIFIER   NOT NULL,
    partner_customer_id         UNIQUEIDENTIFIER   NULL,
    ip_address                  VARCHAR(100)       NULL,
    user_agent                  VARCHAR(500)       NULL,
    used_at                     DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_access_code_usages PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT FK_access_code_usages_codes FOREIGN KEY (partner_access_code_id) REFERENCES dbo.partner_access_codes(id),
    CONSTRAINT FK_access_code_usages_partner_customers FOREIGN KEY (partner_customer_id) REFERENCES dbo.partner_customers(id)
);
GO

CREATE INDEX IX_access_code_usages_code_id
    ON dbo.access_code_usages(partner_access_code_id, used_at DESC);
GO
