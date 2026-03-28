CREATE TABLE dbo.users
(
    id                  UNIQUEIDENTIFIER   NOT NULL,
    partner_id          UNIQUEIDENTIFIER   NULL,
    name                VARCHAR(150)       NOT NULL,
    email               VARCHAR(150)       NOT NULL,
    password_hash       VARCHAR(255)       NOT NULL,
    phone               VARCHAR(30)        NULL,
    status              VARCHAR(30)        NOT NULL,
    user_type           VARCHAR(30)        NOT NULL,
    email_confirmed     BIT                NOT NULL CONSTRAINT DF_users_email_confirmed DEFAULT ((0)),
    last_login_at       DATETIME2(7)       NULL,
    created_at          DATETIME2(7)       NOT NULL,
    updated_at          DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_users PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT UQ_users_email UNIQUE NONCLUSTERED (email ASC),
    CONSTRAINT FK_users_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
    CONSTRAINT CK_users_status CHECK ([status] IN ('pending', 'blocked', 'inactive', 'active')),
    CONSTRAINT CK_users_user_type CHECK ([user_type] IN ('admin', 'partner', 'client', 'partner_customer'))
);
GO

CREATE INDEX IX_users_partner_id
    ON dbo.users(partner_id);
GO

CREATE INDEX IX_users_user_type_status
    ON dbo.users(user_type, status);
GO
