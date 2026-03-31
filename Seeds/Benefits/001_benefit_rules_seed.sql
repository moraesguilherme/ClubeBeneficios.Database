SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   SEED RULES
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.partner_level_rules)
BEGIN
    INSERT INTO dbo.partner_level_rules
    (
        id, level_code, min_active_benefits_each_direction, max_active_benefits_each_direction, created_at, updated_at
    )
    VALUES
    (NEWID(), 'bronze', 1, 1, SYSUTCDATETIME(), SYSUTCDATETIME()),
    (NEWID(), 'silver', 2, 3, SYSUTCDATETIME(), SYSUTCDATETIME()),
    (NEWID(), 'gold', 4, 5, SYSUTCDATETIME(), SYSUTCDATETIME()),
    (NEWID(), 'diamond', 6, 7, SYSUTCDATETIME(), SYSUTCDATETIME()),
    (NEWID(), 'platinum', 8, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.client_level_rules)
BEGIN
    INSERT INTO dbo.client_level_rules
    (
        id, level_code, min_monthly_usage, max_monthly_usage, min_monthly_ticket, max_monthly_ticket, min_points_last_12m, max_points_last_12m, created_at, updated_at
    )
    VALUES
    (NEWID(), 'bronze', 1, 4, 0, 500, 0, 4000, SYSUTCDATETIME(), SYSUTCDATETIME()),
    (NEWID(), 'silver', 5, 9, 501, 999, 4001, 8000, SYSUTCDATETIME(), SYSUTCDATETIME()),
    (NEWID(), 'gold', 10, NULL, 1000, NULL, 8001, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
END
GO