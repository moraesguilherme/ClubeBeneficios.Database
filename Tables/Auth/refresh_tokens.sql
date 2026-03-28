CREATE TABLE dbo.refresh_tokens
(
    id                      UNIQUEIDENTIFIER   NOT NULL,
    session_id              UNIQUEIDENTIFIER   NOT NULL,
    user_id                 UNIQUEIDENTIFIER   NULL,
    partner_customer_id     UNIQUEIDENTIFIER   NULL,
    token                   VARCHAR(500)       NOT NULL,
    expires_at              DATETIME2(7)       NOT NULL,
    created_at              DATETIME2(7)       NOT NULL,
    revoked_at              DATETIME2(7)       NULL,
    replaced_by_token       VARCHAR(500)       NULL,
    created_by_ip           VARCHAR(100)       NULL,

    CONSTRAINT PK_refresh_tokens PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT UQ_refresh_tokens_token UNIQUE NONCLUSTERED (token ASC),
    CONSTRAINT FK_refresh_tokens_sessions FOREIGN KEY (session_id) REFERENCES dbo.sessions(id),
    CONSTRAINT FK_refresh_tokens_users FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_refresh_tokens_partner_customers FOREIGN KEY (partner_customer_id) REFERENCES dbo.partner_customers(id),
    CONSTRAINT CK_refresh_tokens_actor CHECK (
        (CASE WHEN user_id IS NOT NULL THEN 1 ELSE 0 END +
         CASE WHEN partner_customer_id IS NOT NULL THEN 1 ELSE 0 END) = 1
    )
);
GO

CREATE INDEX IX_refresh_tokens_session_id
    ON dbo.refresh_tokens(session_id);
GO

CREATE INDEX IX_refresh_tokens_user_id
    ON dbo.refresh_tokens(user_id);
GO

CREATE INDEX IX_refresh_tokens_partner_customer_id
    ON dbo.refresh_tokens(partner_customer_id);
GO
