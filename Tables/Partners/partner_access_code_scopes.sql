CREATE TABLE dbo.partner_access_code_scopes (
    id UNIQUEIDENTIFIER NOT NULL,
    partner_access_code_id UNIQUEIDENTIFIER NOT NULL,
    scope_type VARCHAR(40) NOT NULL,
    external_reference_id UNIQUEIDENTIFIER NULL,
    external_reference_key VARCHAR(100) NULL,
    created_at DATETIME2(7) NOT NULL,
    CONSTRAINT PK_partner_access_code_scopes PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT FK_partner_access_code_scopes_access_code
        FOREIGN KEY (partner_access_code_id) REFERENCES dbo.partner_access_codes(id),
    CONSTRAINT CK_partner_access_code_scopes_scope_type
        CHECK (scope_type IN (
            'benefit',
            'benefit_group',
            'campaign',
            'catalog',
            'rule'
        ))
);
GO

CREATE INDEX IX_partner_access_code_scopes_access_code
ON dbo.partner_access_code_scopes(partner_access_code_id);
GO