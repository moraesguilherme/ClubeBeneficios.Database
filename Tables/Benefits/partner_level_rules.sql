SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.partner_level_rules', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.partner_level_rules
    (
        id UNIQUEIDENTIFIER NOT NULL,
        level_code VARCHAR(30) NOT NULL,
        min_active_benefits_each_direction INT NOT NULL,
        max_active_benefits_each_direction INT NULL,
        created_at DATETIME2(7) NOT NULL,
        updated_at DATETIME2(7) NOT NULL,

        CONSTRAINT PK_partner_level_rules PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT UQ_partner_level_rules_level_code UNIQUE NONCLUSTERED (level_code),
        CONSTRAINT CK_partner_level_rules_level_code CHECK (level_code IN ('bronze', 'silver', 'gold', 'diamond', 'platinum')),
        CONSTRAINT CK_partner_level_rules_ranges CHECK (
            min_active_benefits_each_direction >= 0
            AND (max_active_benefits_each_direction IS NULL OR max_active_benefits_each_direction >= min_active_benefits_each_direction)
        )
    );
END
GO