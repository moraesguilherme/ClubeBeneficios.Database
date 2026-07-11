CREATE   VIEW [dbo].[vw_benefit_request_pending_summary]
AS
SELECT
    r.partner_id,
    p.trade_name AS partner_name,
    r.benefit_id,
    b.title AS benefit_title,

    COUNT(1) AS total_requests,
    SUM(CASE WHEN r.approval_status = 'pending_review' THEN 1 ELSE 0 END) AS pending_review_count,
    SUM(CASE WHEN r.approval_status = 'under_review' THEN 1 ELSE 0 END) AS under_review_count,
    SUM(CASE WHEN r.approval_status = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(CASE WHEN r.approval_status = 'rejected' THEN 1 ELSE 0 END) AS rejected_count,
    SUM(CASE WHEN r.request_status = 'converted_to_usage' THEN 1 ELSE 0 END) AS converted_to_usage_count,
    MAX(r.requested_at) AS latest_requested_at,
    MAX(r.updated_at) AS latest_updated_at
FROM dbo.benefit_requests r
INNER JOIN dbo.partners p
    ON p.id = r.partner_id
INNER JOIN dbo.benefits b
    ON b.id = r.benefit_id
GROUP BY
    r.partner_id,
    p.trade_name,
    r.benefit_id,
    b.title;
GO

