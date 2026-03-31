SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.client_level_rules', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.client_level_rules
    (
        id UNIQUEIDENTIFIER NOT NULL,
        level_code VARCHAR(30) NOT NULL,
        min_monthly_usage INT NULL,
        max_monthly_usage INT NULL,
        min_monthly_ticket DECIMAL(18,2) NULL,
        max_monthly_ticket DECIMAL(18,2) NULL,
        min_points_last_12m INT NULL,
        max_points_last_12m INT NULL,
        created_at DATETIME2(7) NOT NULL,
        updated_at DATETIME2(7) NOT NULL,

        CONSTRAINT PK_client_level_rules PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT UQ_client_level_rules_level_code UNIQUE NONCLUSTERED (level_code),
        CONSTRAINT CK_client_level_rules_level_code CHECK (level_code IN ('bronze', 'silver', 'gold', 'diamond', 'platinum'))
    );
END
GO