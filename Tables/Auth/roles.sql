CREATE TABLE dbo.roles
(
    id              UNIQUEIDENTIFIER   NOT NULL,
    name            VARCHAR(50)        NOT NULL,
    description     VARCHAR(200)       NULL,
    created_at      DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_roles PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT UQ_roles_name UNIQUE NONCLUSTERED (name ASC)
);
GO
