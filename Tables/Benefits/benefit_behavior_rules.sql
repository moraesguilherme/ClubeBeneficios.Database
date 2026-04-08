    CREATE TABLE dbo.benefit_behavior_rules
    (
        id UNIQUEIDENTIFIER NOT NULL,
        benefit_id UNIQUEIDENTIFIER NOT NULL,
        min_frequency_enabled BIT NOT NULL CONSTRAINT DF_benefit_behavior_rules_min_frequency_enabled DEFAULT ((0)),
        min_frequency_value INT NULL,
        frequency_window_months INT NULL,
        min_ticket_enabled BIT NOT NULL CONSTRAINT DF_benefit_behavior_rules_min_ticket_enabled DEFAULT ((0)),
        min_ticket_value DECIMAL(18,2) NULL,
        ticket_window_months INT NULL,
        first_use_only BIT NOT NULL CONSTRAINT DF_benefit_behavior_rules_first_use_only DEFAULT ((0)),
        requires_matilha_approval BIT NOT NULL CONSTRAINT DF_benefit_behavior_rules_requires_matilha_approval DEFAULT ((0)),
        custom_rule_text VARCHAR(1500) NULL,
        created_at DATETIME2(7) NOT NULL,
        updated_at DATETIME2(7) NOT NULL,

        CONSTRAINT PK_benefit_behavior_rules PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT UQ_benefit_behavior_rules_benefit UNIQUE NONCLUSTERED (benefit_id),
        CONSTRAINT FK_benefit_behavior_rules_benefits FOREIGN KEY (benefit_id) REFERENCES dbo.benefits(id),
        CONSTRAINT CK_benefit_behavior_rules_min_frequency_value CHECK (min_frequency_value IS NULL OR min_frequency_value >= 0),
        CONSTRAINT CK_benefit_behavior_rules_frequency_window CHECK (frequency_window_months IS NULL OR frequency_window_months > 0),
        CONSTRAINT CK_benefit_behavior_rules_min_ticket_value CHECK (min_ticket_value IS NULL OR min_ticket_value >= 0),
        CONSTRAINT CK_benefit_behavior_rules_ticket_window CHECK (ticket_window_months IS NULL OR ticket_window_months > 0)
    );