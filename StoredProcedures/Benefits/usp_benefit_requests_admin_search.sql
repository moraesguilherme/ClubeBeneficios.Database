CREATE   PROCEDURE [dbo].[usp_benefit_requests_admin_search]
    @Search VARCHAR(150) = NULL,
    @RequesterType VARCHAR(30) = NULL,
    @RequestStatus VARCHAR(30) = NULL,
    @ApprovalStatus VARCHAR(30) = NULL,
    @PartnerId UNIQUEIDENTIFIER = NULL,
    @BenefitId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.*
    FROM dbo.vw_benefit_requests_admin_list v
    WHERE
        (@Search IS NULL OR
            v.benefit_title LIKE '%' + @Search + '%'
            OR v.partner_name LIKE '%' + @Search + '%'
            OR v.requester_name LIKE '%' + @Search + '%'
            OR v.pet_name LIKE '%' + @Search + '%')
        AND (@RequesterType IS NULL OR v.requester_type = @RequesterType)
        AND (@RequestStatus IS NULL OR v.request_status = @RequestStatus)
        AND (@ApprovalStatus IS NULL OR v.approval_status = @ApprovalStatus)
        AND (@PartnerId IS NULL OR v.partner_id = @PartnerId)
        AND (@BenefitId IS NULL OR v.benefit_id = @BenefitId)
    ORDER BY v.requested_at DESC, v.created_at DESC;
END
GO


