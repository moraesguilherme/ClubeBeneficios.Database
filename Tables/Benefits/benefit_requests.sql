SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.benefit_requests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.benefit_requests
    (
        id UNIQUEIDENTIFIER NOT NULL,
        benefit_id UNIQUEIDENTIFIER NOT NULL,
        partner_id UNIQUEIDENTIFIER NOT NULL,
        requester_user_id UNIQUEIDENTIFIER NULL,
        requester_partner_customer_id UNIQUEIDENTIFIER NULL,
        requester_type VARCHAR(30) NOT NULL,
        pet_id UNIQUEIDENTIFIER NULL,
        access_code_id UNIQUEIDENTIFIER NULL,
        request_status VARCHAR(30) NOT NULL,
        requested_at DATETIME2(7) NOT NULL,
        reviewed_at DATETIME2(7) NULL,
        reviewed_by_user_id UNIQUEIDENTIFIER NULL,
        review_notes VARCHAR(1500) NULL,
        scheduled_for DATETIME2(7) NULL,
        expires_at DATETIME2(7) NULL,
        created_at DATETIME2(7) NOT NULL,
        updated_at DATETIME2(7) NOT NULL,

        CONSTRAINT PK_benefit_requests PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT FK_benefit_requests_benefits FOREIGN KEY (benefit_id) REFERENCES dbo.benefits(id),
        CONSTRAINT FK_benefit_requests_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
        CONSTRAINT FK_benefit_requests_users_requester FOREIGN KEY (requester_user_id) REFERENCES dbo.users(id),
        CONSTRAINT FK_benefit_requests_partner_customers FOREIGN KEY (requester_partner_customer_id) REFERENCES dbo.partner_customers(id),
        CONSTRAINT FK_benefit_requests_access_codes FOREIGN KEY (access_code_id) REFERENCES dbo.partner_access_codes(id),
        CONSTRAINT FK_benefit_requests_users_reviewed FOREIGN KEY (reviewed_by_user_id) REFERENCES dbo.users(id),
        CONSTRAINT CK_benefit_requests_requester_type CHECK (requester_type IN ('client', 'partner_customer')),
        CONSTRAINT CK_benefit_requests_request_status CHECK (request_status IN ('requested', 'approved', 'declined', 'cancelled', 'expired')),
        CONSTRAINT CK_benefit_requests_requester_presence CHECK (
            (requester_type = 'client' AND requester_user_id IS NOT NULL AND requester_partner_customer_id IS NULL)
            OR
            (requester_type = 'partner_customer' AND requester_partner_customer_id IS NOT NULL AND requester_user_id IS NULL)
        )
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_benefit_requests_benefit_status' AND object_id = OBJECT_ID('dbo.benefit_requests'))
    CREATE INDEX IX_benefit_requests_benefit_status ON dbo.benefit_requests(benefit_id, request_status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_benefit_requests_partner_requested_at' AND object_id = OBJECT_ID('dbo.benefit_requests'))
    CREATE INDEX IX_benefit_requests_partner_requested_at ON dbo.benefit_requests(partner_id, requested_at DESC);
GO