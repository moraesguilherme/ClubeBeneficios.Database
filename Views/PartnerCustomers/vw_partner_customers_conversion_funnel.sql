CREATE   VIEW [dbo].[vw_partner_customers_conversion_funnel]
AS
SELECT
    pc.partner_id,
    p.trade_name AS partner_name,
    COUNT(1) AS total_records,
    SUM(CASE WHEN pc.registration_stage = 'pre_registered' THEN 1 ELSE 0 END) AS pre_registered_count,
    SUM(CASE WHEN pc.registration_stage = 'dashboard_enabled' THEN 1 ELSE 0 END) AS dashboard_enabled_count,
    SUM(CASE WHEN pc.registration_stage = 'profile_completed' THEN 1 ELSE 0 END) AS profile_completed_count,
    SUM(CASE WHEN pc.registration_stage = 'pet_completed' THEN 1 ELSE 0 END) AS pet_completed_count,
    SUM(CASE WHEN pc.registration_stage = 'documents_pending' THEN 1 ELSE 0 END) AS documents_pending_count,
    SUM(CASE WHEN pc.registration_stage = 'under_review' THEN 1 ELSE 0 END) AS under_review_count,
    SUM(CASE WHEN pc.registration_stage = 'eligible' THEN 1 ELSE 0 END) AS eligible_count,
    SUM(CASE WHEN pc.registration_stage = 'ineligible' THEN 1 ELSE 0 END) AS ineligible_count,
    MAX(pc.first_access_at) AS latest_first_access_at,
    MAX(pc.last_access_at) AS latest_last_access_at
FROM dbo.partner_customers pc
INNER JOIN dbo.partners p
    ON p.id = pc.partner_id
GROUP BY
    pc.partner_id,
    p.trade_name;
GO


