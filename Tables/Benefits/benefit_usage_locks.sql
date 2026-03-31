SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.benefit_usage_locks', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.benefit_usage_locks
    (
        id UNIQUEIDENTIFIER NOT NULL,
        benefit_id UNIQUEIDENTIFIER NOT NULL,
        actor_type VARCHAR(30) NOT NULL,
        user_id UNIQUEIDENTIFIER NULL,
        partner_customer_id UNIQUEIDENTIFIER NULL,
        window_start DATETIME2(7) NOT NULL,
        window_end DATETIME2(7) NOT NULL,
        allowed_uses INT NOT NULL,
        used_count INT NOT NULL,
        next_available_at DATETIME2(7) NULL,
        created_at DATETIME2(7) NOT NULL,
        updated_at DATETIME2(7) NOT NULL,

        CONSTRAINT PK_benefit_usage_locks PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT FK_benefit_usage_locks_benefits FOREIGN KEY (benefit_id) REFERENCES dbo.benefits(id),
        CONSTRAINT FK_benefit_usage_locks_users FOREIGN KEY (user_id) REFERENCES dbo.users(id),
        CONSTRAINT FK_benefit_usage_locks_partner_customers FOREIGN KEY (partner_customer_id) REFERENCES dbo.partner_customers(id),
        CONSTRAINT CK_benefit_usage_locks_actor_type CHECK (actor_type IN ('client', 'partner_customer')),
        CONSTRAINT CK_benefit_usage_locks_presence CHECK (
            (actor_type = 'client' AND user_id IS NOT NULL AND partner_customer_id IS NULL)
            OR
            (actor_type = 'partner_customer' AND partner_customer_id IS NOT NULL AND user_id IS NULL)
        ),
        CONSTRAINT CK_benefit_usage_locks_counts CHECK (allowed_uses >= 0 AND used_count >= 0 AND used_count <= allowed_uses),
        CONSTRAINT CK_benefit_usage_locks_window CHECK (window_end >= window_start)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_benefit_usage_locks_lookup_client' AND object_id = OBJECT_ID('dbo.benefit_usage_locks'))
    CREATE INDEX IX_benefit_usage_locks_lookup_client ON dbo.benefit_usage_locks(benefit_id, actor_type, user_id, window_end DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_benefit_usage_locks_lookup_partner_customer' AND object_id = OBJECT_ID('dbo.benefit_usage_locks'))
    CREATE INDEX IX_benefit_usage_locks_lookup_partner_customer ON dbo.benefit_usage_locks(benefit_id, actor_type, partner_customer_id, window_end DESC);
GO