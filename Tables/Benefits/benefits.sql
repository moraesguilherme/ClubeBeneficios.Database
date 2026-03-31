SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   TABLES
   ========================================================= */

IF OBJECT_ID('dbo.benefits', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.benefits
    (
        id UNIQUEIDENTIFIER NOT NULL,
        partner_id UNIQUEIDENTIFIER NOT NULL,
        created_by_user_id UNIQUEIDENTIFIER NULL,
        updated_by_user_id UNIQUEIDENTIFIER NULL,
        approved_by_user_id UNIQUEIDENTIFIER NULL,
        rejected_by_user_id UNIQUEIDENTIFIER NULL,

        title VARCHAR(180) NOT NULL,
        benefit_type VARCHAR(40) NOT NULL,
        direction VARCHAR(30) NOT NULL,
        target_actor_type VARCHAR(30) NOT NULL,
        status VARCHAR(30) NOT NULL,

        short_description VARCHAR(500) NULL,
        full_description VARCHAR(3000) NULL,
        internal_notes VARCHAR(MAX) NULL,

        eligibility_type VARCHAR(30) NOT NULL,
        recurrence_type VARCHAR(40) NOT NULL,
        recurrence_value INT NULL,
        recurrence_period VARCHAR(20) NULL,
        validity_type VARCHAR(30) NOT NULL,

        starts_at DATETIME2(7) NULL,
        ends_at DATETIME2(7) NULL,

        requires_manual_release BIT NOT NULL CONSTRAINT DF_benefits_requires_manual_release DEFAULT ((0)),
        auto_activate_when_approved BIT NOT NULL CONSTRAINT DF_benefits_auto_activate_when_approved DEFAULT ((1)),
        highlight_in_showcase BIT NOT NULL CONSTRAINT DF_benefits_highlight_in_showcase DEFAULT ((0)),
        allow_first_use_only BIT NOT NULL CONSTRAINT DF_benefits_allow_first_use_only DEFAULT ((0)),
        requires_active_access_code BIT NOT NULL CONSTRAINT DF_benefits_requires_active_access_code DEFAULT ((0)),
        requires_partner_availability BIT NOT NULL CONSTRAINT DF_benefits_requires_partner_availability DEFAULT ((1)),
        requires_matilha_acceptance_rules BIT NOT NULL CONSTRAINT DF_benefits_requires_matilha_acceptance_rules DEFAULT ((0)),

        stacking_rule VARCHAR(30) NOT NULL CONSTRAINT DF_benefits_stacking_rule DEFAULT ('non_cumulative'),
        approval_notes VARCHAR(1500) NULL,
        rejection_reason VARCHAR(1500) NULL,
        approved_at DATETIME2(7) NULL,
        rejected_at DATETIME2(7) NULL,
        inactivated_at DATETIME2(7) NULL,
        created_at DATETIME2(7) NOT NULL,
        updated_at DATETIME2(7) NOT NULL,

        CONSTRAINT PK_benefits PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT FK_benefits_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
        CONSTRAINT FK_benefits_users_created FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id),
        CONSTRAINT FK_benefits_users_updated FOREIGN KEY (updated_by_user_id) REFERENCES dbo.users(id),
        CONSTRAINT FK_benefits_users_approved FOREIGN KEY (approved_by_user_id) REFERENCES dbo.users(id),
        CONSTRAINT FK_benefits_users_rejected FOREIGN KEY (rejected_by_user_id) REFERENCES dbo.users(id),

        CONSTRAINT CK_benefits_benefit_type CHECK (benefit_type IN (
            'discount', 'service', 'gift', 'daily_rate', 'evaluation', 'upgrade', 'raffle', 'event', 'experience', 'custom'
        )),
        CONSTRAINT CK_benefits_direction CHECK (direction IN (
            'partner_to_matilha', 'matilha_to_partner'
        )),
        CONSTRAINT CK_benefits_target_actor_type CHECK (target_actor_type IN (
            'client', 'partner_customer'
        )),
        CONSTRAINT CK_benefits_status CHECK (status IN (
            'draft', 'pending_review', 'under_review', 'approved', 'active', 'inactive', 'rejected', 'expired', 'archived'
        )),
        CONSTRAINT CK_benefits_eligibility_type CHECK (eligibility_type IN (
            'open', 'level', 'behavior', 'code', 'hybrid'
        )),
        CONSTRAINT CK_benefits_recurrence_type CHECK (recurrence_type IN (
            'once_per_customer', 'limited_per_period', 'unlimited_within_rule', 'first_use_only'
        )),
        CONSTRAINT CK_benefits_recurrence_period CHECK (
            recurrence_period IS NULL OR recurrence_period IN ('day', 'week', 'month', 'quarter', 'semester', 'year')
        ),
        CONSTRAINT CK_benefits_validity_type CHECK (validity_type IN (
            'continuous', 'date_range', 'until_stock', 'campaign_period'
        )),
        CONSTRAINT CK_benefits_stacking_rule CHECK (stacking_rule IN (
            'non_cumulative', 'allow_with_campaign', 'allow_with_fidelity'
        )),
        CONSTRAINT CK_benefits_dates CHECK (ends_at IS NULL OR starts_at IS NULL OR ends_at >= starts_at),
        CONSTRAINT CK_benefits_recurrence_value CHECK (recurrence_value IS NULL OR recurrence_value >= 0)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_benefits_partner_status' AND object_id = OBJECT_ID('dbo.benefits'))
    CREATE INDEX IX_benefits_partner_status ON dbo.benefits(partner_id, status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_benefits_direction_target_status' AND object_id = OBJECT_ID('dbo.benefits'))
    CREATE INDEX IX_benefits_direction_target_status ON dbo.benefits(direction, target_actor_type, status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_benefits_created_at' AND object_id = OBJECT_ID('dbo.benefits'))
    CREATE INDEX IX_benefits_created_at ON dbo.benefits(created_at DESC);
GO