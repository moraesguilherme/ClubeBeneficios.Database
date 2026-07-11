CREATE   PROCEDURE [dbo].[usp_benefit_requests_pending_review_search]
    @Search VARCHAR(150) = NULL,
    @RequesterType VARCHAR(30) = NULL,
    @ApprovalStatus VARCHAR(30) = NULL,
    @PartnerId UNIQUEIDENTIFIER = NULL,
    @BenefitId UNIQUEIDENTIFIER = NULL,
    @OnlyExpired BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        q.*
    FROM dbo.vw_benefit_request_approval_queue q
    WHERE
        (@Search IS NULL OR
            q.benefit_title LIKE '%' + @Search + '%'
            OR q.partner_name LIKE '%' + @Search + '%'
            OR q.requester_name LIKE '%' + @Search + '%'
            OR q.pet_name LIKE '%' + @Search + '%'
            OR q.access_code LIKE '%' + @Search + '%')
        AND (@RequesterType IS NULL OR q.requester_type = @RequesterType)
        AND (@ApprovalStatus IS NULL OR q.approval_status = @ApprovalStatus)
        AND (@PartnerId IS NULL OR q.partner_id = @PartnerId)
        AND (@BenefitId IS NULL OR q.benefit_id = @BenefitId)
        AND (@OnlyExpired = 0 OR q.is_expired = 1)
    ORDER BY
        CASE WHEN q.approval_status = 'pending_review' THEN 0 ELSE 1 END,
        q.approval_requested_at DESC,
        q.requested_at DESC;
END
GO

