CREATE TABLE dbo.password_reset_tokens
(
    id              UNIQUEIDENTIFIER   NOT NULL,
    user_id         UNIQUEIDENTIFIER   NOT NULL,
    token           VARCHAR(500)       NOT NULL,
    expires_at      DATETIME2(7)       NOT NULL,
    created_at      DATETIME2(7)       NOT NULL,
    used_at         DATETIME2(7)       NULL,

    CONSTRAINT PK_password_reset_tokens PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT UQ_password_reset_tokens_token UNIQUE NONCLUSTERED (token ASC),
    CONSTRAINT FK_password_reset_tokens_users FOREIGN KEY (user_id) REFERENCES dbo.users(id)
);
GO

CREATE INDEX IX_password_reset_tokens_user_id
    ON dbo.password_reset_tokens(user_id);
GO
