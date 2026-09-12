IF OBJECT_ID('dbo.app_settings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.app_settings
    (
        setting_key VARCHAR(120) NOT NULL CONSTRAINT PK_app_settings PRIMARY KEY,
        setting_value VARCHAR(1000) NOT NULL,
        description VARCHAR(500) NULL,
        created_at DATETIME2(7) NOT NULL CONSTRAINT DF_app_settings_created_at DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(7) NOT NULL CONSTRAINT DF_app_settings_updated_at DEFAULT SYSUTCDATETIME()
    );
END
GO

IF OBJECT_ID('dbo.app_settings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.app_settings
    (
        setting_key VARCHAR(120) NOT NULL CONSTRAINT PK_app_settings PRIMARY KEY,
        setting_value VARCHAR(1000) NOT NULL,
        description VARCHAR(500) NULL,
        created_at DATETIME2(7) NOT NULL CONSTRAINT DF_app_settings_created_at DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(7) NOT NULL CONSTRAINT DF_app_settings_updated_at DEFAULT SYSUTCDATETIME()
    );
END
GO