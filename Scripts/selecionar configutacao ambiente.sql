MERGE dbo.app_settings AS target
USING
(
    SELECT
        'FrontPublicBaseUrl' AS setting_key,
        'http://localhost:5173' AS setting_value,
        'URL pública do front usada em links enviados por e-mail.' AS description
) AS source
ON target.setting_key = source.setting_key
WHEN MATCHED THEN
    UPDATE SET
        setting_value = source.setting_value,
        description = source.description,
        updated_at = SYSUTCDATETIME()
WHEN NOT MATCHED THEN
    INSERT
    (
        setting_key,
        setting_value,
        description,
        created_at,
        updated_at
    )
    VALUES
    (
        source.setting_key,
        source.setting_value,
        source.description,
        SYSUTCDATETIME(),
        SYSUTCDATETIME()
    );
GO

-- mudar para homolog 

--UPDATE dbo.app_settings
--SET
--    setting_value = 'http://135.232.249.243:5173',
--    updated_at = SYSUTCDATETIME()
--WHERE setting_key = 'FrontPublicBaseUrl';