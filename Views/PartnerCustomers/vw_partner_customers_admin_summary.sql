CREATE   VIEW [dbo].[vw_partner_customers_admin_summary]
AS
SELECT
    COUNT(1) AS total_partner_customers,
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS active_count,
    SUM(CASE WHEN status = 'inactive' THEN 1 ELSE 0 END) AS inactive_count,
    SUM(CASE WHEN status = 'blocked' THEN 1 ELSE 0 END) AS blocked_count,
    SUM(CASE WHEN registration_stage = 'pre_registered' THEN 1 ELSE 0 END) AS pre_registered_count,
    SUM(CASE WHEN registration_stage = 'dashboard_enabled' THEN 1 ELSE 0 END) AS dashboard_enabled_count,
    SUM(CASE WHEN registration_stage = 'profile_completed' THEN 1 ELSE 0 END) AS profile_completed_count,
    SUM(CASE WHEN registration_stage = 'pet_completed' THEN 1 ELSE 0 END) AS pet_completed_count,
    SUM(CASE WHEN registration_stage = 'documents_pending' THEN 1 ELSE 0 END) AS documents_pending_count,
    SUM(CASE WHEN registration_stage = 'under_review' THEN 1 ELSE 0 END) AS under_review_count,
    SUM(CASE WHEN registration_stage = 'eligible' THEN 1 ELSE 0 END) AS eligible_count,
    SUM(CASE WHEN registration_stage = 'ineligible' THEN 1 ELSE 0 END) AS ineligible_count,
    MAX(created_at) AS latest_created_at,
    MAX(updated_at) AS latest_updated_at
FROM dbo.partner_customers;
GO


