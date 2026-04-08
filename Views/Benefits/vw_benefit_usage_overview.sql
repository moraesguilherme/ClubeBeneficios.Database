CREATE VIEW dbo.vw_benefit_usage_overview
AS
SELECT
    u.id,
    u.benefit_id,
    u.partner_id,
    p.trade_name AS partner_name,
    u.used_by_type,
    u.usage_status,
    u.used_at,
    u.snapshot_title,
    u.snapshot_partner_name,
    u.monetary_value,
    u.discount_value
FROM dbo.benefit_usages u
INNER JOIN dbo.partners p ON p.id = u.partner_id;
GO