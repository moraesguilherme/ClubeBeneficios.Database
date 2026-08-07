CREATE   PROCEDURE [dbo].[usp_benefit_requests_approval_dashboard_summary]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(1) AS total_queue_items,
        SUM(CASE WHEN approval_status = 'pending_review' THEN 1 ELSE 0 END) AS pending_review_count,
        SUM(CASE WHEN approval_status = 'under_review' THEN 1 ELSE 0 END) AS under_review_count,
        SUM(CASE WHEN approval_status = 'approved' THEN 1 ELSE 0 END) AS approved_count,
        SUM(CASE WHEN approval_status = 'rejected' THEN 1 ELSE 0 END) AS rejected_count,
        SUM(CASE WHEN is_expired = 1 THEN 1 ELSE 0 END) AS expired_count,
        MAX(requested_at) AS latest_requested_at
    FROM dbo.vw_benefit_request_approval_queue;
END
GO

