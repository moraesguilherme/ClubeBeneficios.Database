CREATE   VIEW [dbo].[vw_partner_customer_benefit_dashboard_summary]
AS
SELECT
    pc.id AS partner_customer_id,
    pc.partner_id,
    p.trade_name AS partner_name,
    pc.full_name,
    pc.email,
    pc.phone,
    pc.status,
    pc.registration_stage,

    COUNT(DISTINCT r.id) AS total_requests,
    SUM(CASE WHEN r.request_status = 'requested' THEN 1 ELSE 0 END) AS requested_count,
    SUM(CASE WHEN r.request_status = 'pending_review' THEN 1 ELSE 0 END) AS pending_review_count,
    SUM(CASE WHEN r.request_status = 'under_review' THEN 1 ELSE 0 END) AS under_review_count,
    SUM(CASE WHEN r.request_status = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(CASE WHEN r.request_status = 'declined' THEN 1 ELSE 0 END) AS declined_count,
    SUM(CASE WHEN r.request_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
    SUM(CASE WHEN r.request_status = 'expired' THEN 1 ELSE 0 END) AS expired_count,
    SUM(CASE WHEN r.request_status = 'converted_to_usage' THEN 1 ELSE 0 END) AS converted_to_usage_count,

    COUNT(DISTINCT u.id) AS total_usages,
    MAX(r.requested_at) AS last_request_at,
    MAX(u.used_at) AS last_usage_at
FROM dbo.partner_customers pc
INNER JOIN dbo.partners p
    ON p.id = pc.partner_id
LEFT JOIN dbo.benefit_requests r
    ON r.requester_type = 'partner_customer'
   AND r.requester_partner_customer_id = pc.id
LEFT JOIN dbo.benefit_usages u
    ON u.used_by_type = 'partner_customer'
   AND u.used_by_partner_customer_id = pc.id
GROUP BY
    pc.id,
    pc.partner_id,
    p.trade_name,
    pc.full_name,
    pc.email,
    pc.phone,
    pc.status,
    pc.registration_stage;
GO


