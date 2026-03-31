SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   VIEWS
   ========================================================= */

CREATE OR ALTER VIEW dbo.vw_benefits_admin_list
AS
SELECT
    b.id,
    b.partner_id,
    p.trade_name AS partner_name,
    p.level AS partner_level,
    b.title,
    b.benefit_type,
    b.direction,
    b.target_actor_type,
    b.status,
    b.eligibility_type,
    b.validity_type,
    b.starts_at,
    b.ends_at,
    b.highlight_in_showcase,
    b.requires_manual_release,
    ISNULL(ms.requests_count, 0) AS requests_count,
    ISNULL(ms.usages_count, 0) AS usages_count,
    ISNULL(ms.conversion_rate, 0) AS conversion_rate,
    b.created_at,
    b.updated_at
FROM dbo.benefits b
INNER JOIN dbo.partners p ON p.id = b.partner_id
LEFT JOIN dbo.benefit_metrics_snapshot ms ON ms.benefit_id = b.id;
GO