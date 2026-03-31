SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.benefit_code_rules', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.benefit_code_rules
    (
        id UNIQUEIDENTIFIER NOT NULL,
        benefit_id UNIQUEIDENTIFIER NOT NULL,
        requires_access_code BIT NOT NULL CONSTRAINT DF_benefit_code_rules_requires_access_code DEFAULT ((0)),
        allow_any_active_partner_code BIT NOT NULL CONSTRAINT DF_benefit_code_rules_allow_any_active_partner_code DEFAULT ((1)),
        specific_access_code_id UNIQUEIDENTIFIER NULL,
        code_validation_mode VARCHAR(30) NOT NULL CONSTRAINT DF_benefit_code_rules_code_validation_mode DEFAULT ('partner_code'),
        created_at DATETIME2(7) NOT NULL,
        updated_at DATETIME2(7) NOT NULL,

        CONSTRAINT PK_benefit_code_rules PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT UQ_benefit_code_rules_benefit UNIQUE NONCLUSTERED (benefit_id),
        CONSTRAINT FK_benefit_code_rules_benefits FOREIGN KEY (benefit_id) REFERENCES dbo.benefits(id),
        CONSTRAINT FK_benefit_code_rules_access_codes FOREIGN KEY (specific_access_code_id) REFERENCES dbo.partner_access_codes(id),
        CONSTRAINT CK_benefit_code_rules_code_validation_mode CHECK (code_validation_mode IN ('partner_code', 'matilha_coupon', 'invite_code'))
    );
END
GO