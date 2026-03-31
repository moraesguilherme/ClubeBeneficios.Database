SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.benefit_level_scopes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.benefit_level_scopes
    (
        id UNIQUEIDENTIFIER NOT NULL,
        benefit_id UNIQUEIDENTIFIER NOT NULL,
        level_type VARCHAR(30) NOT NULL,
        level_code VARCHAR(30) NOT NULL,
        created_at DATETIME2(7) NOT NULL,

        CONSTRAINT PK_benefit_level_scopes PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT FK_benefit_level_scopes_benefits FOREIGN KEY (benefit_id) REFERENCES dbo.benefits(id),
        CONSTRAINT CK_benefit_level_scopes_level_type CHECK (level_type IN ('partner_level', 'client_level')),
        CONSTRAINT CK_benefit_level_scopes_level_code CHECK (level_code IN ('bronze', 'silver', 'gold', 'diamond', 'platinum'))
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_benefit_level_scopes_benefit' AND object_id = OBJECT_ID('dbo.benefit_level_scopes'))
    CREATE INDEX IX_benefit_level_scopes_benefit ON dbo.benefit_level_scopes(benefit_id);
GO