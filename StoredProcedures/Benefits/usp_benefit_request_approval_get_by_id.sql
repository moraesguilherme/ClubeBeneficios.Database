CREATE   PROCEDURE [dbo].[usp_benefit_request_approval_get_by_id]
    @BenefitRequestId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_benefit_request_approval_queue
    WHERE id = @BenefitRequestId;

    SELECT
        rr.id,
        rr.benefit_request_id,
        rr.review_status,
        rr.review_point,
        rr.review_recommendation,
        rr.reviewed_by_user_id,
        rr.reviewed_at,
        rr.created_at
    FROM dbo.benefit_request_reviews rr
    WHERE rr.benefit_request_id = @BenefitRequestId
    ORDER BY rr.reviewed_at DESC, rr.created_at DESC;
END
GO


