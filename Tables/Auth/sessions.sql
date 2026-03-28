CREATE TABLE dbo.sessions
(
    id                      UNIQUEIDENTIFIER   NOT NULL,
    user_id                 UNIQUEIDENTIFIER   NULL,
    partner_customer_id     UNIQUEIDENTIFIER   NULL,
    access_token_jti        VARCHAR(100)       NOT NULL,
    ip_address              VARCHAR(100)       NULL,
    user_agent              VARCHAR(500)       NULL,
    created_at              DATETIME2(7)       NOT NULL,
    expires_at              DATETIME2(7)       NOT NULL,
    revoked_at              DATETIME2(7)       NULL,
    is_valid                BIT                NOT NULL CONSTRAINT DF_sessions_is_valid DEFAULT ((1)),

    CONSTRAINT PK_sessions PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT UQ_sessions_access_token_jti UNIQUE NONCLUSTERED (access_token_jti ASC),
    CONSTRAINT FK_sessions_users FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_sessions_partner_customers FOREIGN KEY (partner_customer_id) REFERENCES dbo.partner_customers(id),
    CONSTRAINT CK_sessions_actor CHECK (
        (CASE WHEN user_id IS NOT NULL THEN 1 ELSE 0 END +
         CASE WHEN partner_customer_id IS NOT NULL THEN 1 ELSE 0 END) = 1
    )
);
GO

CREATE INDEX IX_sessions_user_id
    ON dbo.sessions(user_id);
GO

CREATE INDEX IX_sessions_partner_customer_id
    ON dbo.sessions(partner_customer_id);
GO
