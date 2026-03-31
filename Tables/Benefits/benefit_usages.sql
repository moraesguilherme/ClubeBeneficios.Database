SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.benefit_usages', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.benefit_usages
    (
        id UNIQUEIDENTIFIER NOT NULL,
        benefit_request_id UNIQUEIDENTIFIER NULL,
        benefit_id UNIQUEIDENTIFIER NOT NULL,
        partner_id UNIQUEIDENTIFIER NOT NULL,
        used_by_user_id UNIQUEIDENTIFIER NULL,
        used_by_partner_customer_id UNIQUEIDENTIFIER NULL,
        used_by_type VARCHAR(30) NOT NULL,
        pet_id UNIQUEIDENTIFIER NULL,
        usage_status VARCHAR(30) NOT NULL,
        used_at DATETIME2(7) NOT NULL,
        confirmed_by_partner_user_id UNIQUEIDENTIFIER NULL,
        confirmed_by_admin_user_id UNIQUEIDENTIFIER NULL,
        monetary_value DECIMAL(18,2) NULL,
        discount_value DECIMAL(18,2) NULL,
        snapshot_title VARCHAR(180) NOT NULL,
        snapshot_partner_name VARCHAR(150) NOT NULL,
        snapshot_rule_summary VARCHAR(1000) NULL,
        created_at DATETIME2(7) NOT NULL,
        updated_at DATETIME2(7) NOT NULL,

        CONSTRAINT PK_benefit_usages PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT FK_benefit_usages_requests FOREIGN KEY (benefit_request_id) REFERENCES dbo.benefit_requests(id),
        CONSTRAINT FK_benefit_usages_benefits FOREIGN KEY (benefit_id) REFERENCES dbo.benefits(id),
        CONSTRAINT FK_benefit_usages_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
        CONSTRAINT FK_benefit_usages_users_used_by FOREIGN KEY (used_by_user_id) REFERENCES dbo.users(id),
        CONSTRAINT FK_benefit_usages_partner_customers FOREIGN KEY (used_by_partner_customer_id) REFERENCES dbo.partner_customers(id),
        CONSTRAINT FK_benefit_usages_partner_users FOREIGN KEY (confirmed_by_partner_user_id) REFERENCES dbo.users(id),
        CONSTRAINT FK_benefit_usages_admin_users FOREIGN KEY (confirmed_by_admin_user_id) REFERENCES dbo.users(id),
        CONSTRAINT CK_benefit_usages_used_by_type CHECK (used_by_type IN ('client', 'partner_customer')),
        CONSTRAINT CK_benefit_usages_status CHECK (usage_status IN ('confirmed', 'used', 'cancelled', 'no_show', 'reversed')),
        CONSTRAINT CK_benefit_usages_user_presence CHECK (
            (used_by_type = 'client' AND used_by_user_id IS NOT NULL AND used_by_partner_customer_id IS NULL)
            OR
            (used_by_type = 'partner_customer' AND used_by_partner_customer_id IS NOT NULL AND used_by_user_id IS NULL)
        ),
        CONSTRAINT CK_benefit_usages_values CHECK (
            (monetary_value IS NULL OR monetary_value >= 0)
            AND
            (discount_value IS NULL OR discount_value >= 0)
        )
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_benefit_usages_benefit_used_at' AND object_id = OBJECT_ID('dbo.benefit_usages'))
    CREATE INDEX IX_benefit_usages_benefit_used_at ON dbo.benefit_usages(benefit_id, used_at DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_benefit_usages_partner_used_at' AND object_id = OBJECT_ID('dbo.benefit_usages'))
    CREATE INDEX IX_benefit_usages_partner_used_at ON dbo.benefit_usages(partner_id, used_at DESC);
GO