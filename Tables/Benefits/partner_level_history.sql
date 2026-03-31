SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.partner_level_history', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.partner_level_history
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        partner_id UNIQUEIDENTIFIER NOT NULL,
        level_code VARCHAR(30) NOT NULL,
        calculation_reference_date DATE NOT NULL,
        assigned_at DATETIME2(7) NOT NULL,
        changed_reason VARCHAR(500) NULL,
        changed_by_user_id UNIQUEIDENTIFIER NULL,

        CONSTRAINT PK_partner_level_history PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT FK_partner_level_history_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
        CONSTRAINT FK_partner_level_history_users FOREIGN KEY (changed_by_user_id) REFERENCES dbo.users(id),
        CONSTRAINT CK_partner_level_history_level_code CHECK (level_code IN ('bronze', 'silver', 'gold', 'diamond', 'platinum'))
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_partner_level_history_partner_assigned_at' AND object_id = OBJECT_ID('dbo.partner_level_history'))
    CREATE INDEX IX_partner_level_history_partner_assigned_at ON dbo.partner_level_history(partner_id, assigned_at DESC);
GO