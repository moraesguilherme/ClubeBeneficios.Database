SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.benefit_status_history', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.benefit_status_history
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        benefit_id UNIQUEIDENTIFIER NOT NULL,
        from_status VARCHAR(30) NULL,
        to_status VARCHAR(30) NOT NULL,
        reason VARCHAR(1500) NULL,
        changed_by_user_id UNIQUEIDENTIFIER NULL,
        changed_at DATETIME2(7) NOT NULL,

        CONSTRAINT PK_benefit_status_history PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT FK_benefit_status_history_benefits FOREIGN KEY (benefit_id) REFERENCES dbo.benefits(id),
        CONSTRAINT FK_benefit_status_history_users FOREIGN KEY (changed_by_user_id) REFERENCES dbo.users(id),
        CONSTRAINT CK_benefit_status_history_to_status CHECK (to_status IN (
            'draft', 'pending_review', 'under_review', 'approved', 'active', 'inactive', 'rejected', 'expired', 'archived'
        ))
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_benefit_status_history_benefit_changed_at' AND object_id = OBJECT_ID('dbo.benefit_status_history'))
    CREATE INDEX IX_benefit_status_history_benefit_changed_at ON dbo.benefit_status_history(benefit_id, changed_at DESC);
GO