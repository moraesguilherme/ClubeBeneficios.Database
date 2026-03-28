CREATE TABLE dbo.user_roles
(
    id              UNIQUEIDENTIFIER   NOT NULL,
    user_id         UNIQUEIDENTIFIER   NOT NULL,
    role_id         UNIQUEIDENTIFIER   NOT NULL,
    created_at      DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_user_roles PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT FK_user_roles_users FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_user_roles_roles FOREIGN KEY (role_id) REFERENCES dbo.roles(id)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_user_roles_user_role
    ON dbo.user_roles(user_id, role_id);
GO
