SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.customer_level_history', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.customer_level_history
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        user_id UNIQUEIDENTIFIER NOT NULL,
        level_code VARCHAR(30) NOT NULL,
        calculation_reference_date DATE NOT NULL,
        assigned_at DATETIME2(7) NOT NULL,
        expires_at DATETIME2(7) NULL,
        changed_reason VARCHAR(500) NULL,
        changed_by_user_id UNIQUEIDENTIFIER NULL,

        CONSTRAINT PK_customer_level_history PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT FK_customer_level_history_users FOREIGN KEY (user_id) REFERENCES dbo.users(id),
        CONSTRAINT FK_customer_level_history_changed_users FOREIGN KEY (changed_by_user_id) REFERENCES dbo.users(id),
        CONSTRAINT CK_customer_level_history_level_code CHECK (level_code IN ('bronze', 'silver', 'gold', 'diamond', 'platinum'))
    );
END
GO