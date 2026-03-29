CREATE TABLE dbo.partners
(
    id UNIQUEIDENTIFIER NOT NULL,
    trade_name VARCHAR(150) NOT NULL,
    legal_name VARCHAR(150) NULL,
    document VARCHAR(30) NULL,
    email VARCHAR(150) NULL,
    phone VARCHAR(30) NULL,
    status VARCHAR(30) NOT NULL,
    logo_url VARCHAR(500) NULL,
    segment VARCHAR(120) NULL,
    category VARCHAR(120) NULL,
    service_region VARCHAR(180) NULL,
    website VARCHAR(250) NULL,
    instagram VARCHAR(150) NULL,
    description VARCHAR(1200) NULL,
    level VARCHAR(30) NULL,
    indication_flow_enabled BIT NOT NULL
        CONSTRAINT DF_partners_indication_flow_enabled DEFAULT ((1)),
    access_code_flow_enabled BIT NOT NULL
        CONSTRAINT DF_partners_access_code_flow_enabled DEFAULT ((1)),
    origin_type VARCHAR(30) NOT NULL
        CONSTRAINT DF_partners_origin_type DEFAULT ('admin_created'),
    created_by_user_id UNIQUEIDENTIFIER NULL,
    approved_by_user_id UNIQUEIDENTIFIER NULL,
    rejected_by_user_id UNIQUEIDENTIFIER NULL,
    approved_at DATETIME2(7) NULL,
    rejected_at DATETIME2(7) NULL,
    inactivated_at DATETIME2(7) NULL,
    created_at DATETIME2(7) NOT NULL,
    updated_at DATETIME2(7) NOT NULL,

    CONSTRAINT PK_partners
        PRIMARY KEY CLUSTERED (id ASC),

    CONSTRAINT CK_partners_status
        CHECK ([status] IN (
            'pending_review',
            'under_review',
            'approved',
            'active',
            'inactive',
            'rejected',
            'suspended',
            'blocked'
        )),

    CONSTRAINT CK_partners_level
        CHECK ([level] IS NULL OR [level] IN (
            'bronze',
            'silver',
            'gold',
            'diamond',
            'platinum'
        )),

    CONSTRAINT CK_partners_origin_type
        CHECK ([origin_type] IN (
            'admin_created',
            'self_signup',
            'migration',
            'api'
        ))
);
GO