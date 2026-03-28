CREATE TABLE dbo.access_logs
(
    id                      UNIQUEIDENTIFIER   NOT NULL,
    user_id                 UNIQUEIDENTIFIER   NULL,
    partner_customer_id     UNIQUEIDENTIFIER   NULL,
    partner_id              UNIQUEIDENTIFIER   NULL,
    session_id              UNIQUEIDENTIFIER   NULL,
    action                  VARCHAR(100)       NOT NULL,
    resource                VARCHAR(100)       NULL,
    ip_address              VARCHAR(100)       NULL,
    user_agent              VARCHAR(500)       NULL,
    success                 BIT                NOT NULL,
    details                 VARCHAR(1000)      NULL,
    created_at              DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_access_logs PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT FK_access_logs_users FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_access_logs_partner_customers FOREIGN KEY (partner_customer_id) REFERENCES dbo.partner_customers(id),
    CONSTRAINT FK_access_logs_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
    CONSTRAINT FK_access_logs_sessions FOREIGN KEY (session_id) REFERENCES dbo.sessions(id)
);
GO

CREATE INDEX IX_access_logs_user_id
    ON dbo.access_logs(user_id, created_at DESC);
GO

CREATE INDEX IX_access_logs_partner_customer_id
    ON dbo.access_logs(partner_customer_id, created_at DESC);
GO

CREATE INDEX IX_access_logs_partner_id
    ON dbo.access_logs(partner_id, created_at DESC);
GO
