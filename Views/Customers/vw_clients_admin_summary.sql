CREATE   VIEW [dbo].[vw_clients_admin_summary]
AS
SELECT
    COUNT(1) AS total_clients,
    SUM(CASE WHEN status = 'lead' THEN 1 ELSE 0 END) AS lead_count,
    SUM(CASE WHEN status = 'pending_profile' THEN 1 ELSE 0 END) AS pending_profile_count,
    SUM(CASE WHEN status = 'pending_documents' THEN 1 ELSE 0 END) AS pending_documents_count,
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS active_count,
    SUM(CASE WHEN status = 'inactive' THEN 1 ELSE 0 END) AS inactive_count,
    SUM(CASE WHEN status = 'blocked' THEN 1 ELSE 0 END) AS blocked_count,
    MAX(created_at) AS latest_created_at,
    MAX(updated_at) AS latest_updated_at
FROM dbo.clients;
GO


