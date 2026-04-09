CREATE   VIEW [dbo].[vw_benefits_pending_list]
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
    b.short_description,
    b.created_at,
    latest_review.review_status AS latest_review_status,
    latest_review.review_point,
    latest_review.review_recommendation,
    latest_review.reviewed_at
FROM dbo.benefits b
INNER JOIN dbo.partners p ON p.id = b.partner_id
OUTER APPLY
(
    SELECT TOP (1)
        r.review_status,
        r.review_point,
        r.review_recommendation,
        r.reviewed_at
    FROM dbo.benefit_reviews r
    WHERE r.benefit_id = b.id
    ORDER BY r.reviewed_at DESC
) latest_review
WHERE b.status IN ('pending_review', 'under_review');

GO


