CREATE VIEW dbo.vw_partners_admin_list
AS
SELECT
    p.id,
    p.trade_name,
    p.legal_name,
    p.document,
    p.email,
    p.phone,
    p.status,
    p.logo_url,
    p.segment,
    p.category,
    p.service_region,
    p.website,
    p.instagram,
    p.description,
    p.level,
    p.indication_flow_enabled,
    p.access_code_flow_enabled,
    p.origin_type,
    p.created_at,
    p.updated_at,
    p.approved_at,
    p.rejected_at,
    p.inactivated_at,
    p.created_by_user_id,
    p.approved_by_user_id,
    p.rejected_by_user_id,

    c.name AS responsible_name,
    c.role_name AS responsible_role,
    c.email AS responsible_email,
    c.phone AS responsible_phone,

    ISNULL(ms.benefits_count, 0) AS benefits_count,
    ISNULL(ms.converted_clients_count, 0) AS converted_clients_count,
    ISNULL(ms.campaigns_count, 0) AS campaigns_count,
    ISNULL(ms.raffles_count, 0) AS raffles_count,
    ms.performance_score,
    ms.refreshed_at AS metrics_refreshed_at
FROM dbo.partners p
LEFT JOIN dbo.partner_contacts c
    ON c.partner_id = p.id
   AND c.is_primary = 1
LEFT JOIN dbo.partner_metrics_snapshot ms
    ON ms.partner_id = p.id;
GO
