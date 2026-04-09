CREATE   PROCEDURE [dbo].[usp_partners_admin_summary]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(1) AS total_partners,
        SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS active_partners,
        SUM(CASE WHEN status = 'pending_review' THEN 1 ELSE 0 END) AS pending_review_partners,
        SUM(CASE WHEN status = 'under_review' THEN 1 ELSE 0 END) AS under_review_partners,
        SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) AS approved_partners,
        SUM(CASE WHEN status = 'inactive' THEN 1 ELSE 0 END) AS inactive_partners,
        SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) AS rejected_partners,
        SUM(CASE WHEN status = 'suspended' THEN 1 ELSE 0 END) AS suspended_partners,
        SUM(CASE WHEN status = 'blocked' THEN 1 ELSE 0 END) AS blocked_partners,
        SUM(CASE WHEN level = 'bronze' THEN 1 ELSE 0 END) AS bronze_count,
        SUM(CASE WHEN level = 'silver' THEN 1 ELSE 0 END) AS silver_count,
        SUM(CASE WHEN level = 'gold' THEN 1 ELSE 0 END) AS gold_count,
        SUM(CASE WHEN level = 'diamond' THEN 1 ELSE 0 END) AS diamond_count,
        SUM(CASE WHEN level = 'platinum' THEN 1 ELSE 0 END) AS platinum_count
    FROM dbo.partners;
END
GO


