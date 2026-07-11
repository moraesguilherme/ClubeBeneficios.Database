CREATE   PROCEDURE [dbo].[usp_benefit_requests_admin_search]
    @Search VARCHAR(200) = NULL,
    @BenefitId UNIQUEIDENTIFIER = NULL,
    @PartnerId UNIQUEIDENTIFIER = NULL,
    @RequestStatus VARCHAR(30) = NULL,
    @RequesterType VARCHAR(30) = NULL,
    @RequestedFrom DATETIME2(7) = NULL,
    @RequestedTo DATETIME2(7) = NULL,
    @Page INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @Page IS NULL OR @Page <= 0
        SET @Page = 1;

    IF @PageSize IS NULL OR @PageSize <= 0
        SET @PageSize = 20;

    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    DECLARE @TotalCount INT;

    SELECT
        @TotalCount = COUNT(1)
    FROM dbo.vw_benefit_requests_admin_list v
    WHERE
        (@Search IS NULL
            OR v.benefit_title LIKE '%' + @Search + '%'
            OR v.partner_name LIKE '%' + @Search + '%'
            OR v.requester_name LIKE '%' + @Search + '%'
            OR v.pet_name LIKE '%' + @Search + '%')
        AND (@BenefitId IS NULL OR v.benefit_id = @BenefitId)
        AND (@PartnerId IS NULL OR v.partner_id = @PartnerId)
        AND (@RequestStatus IS NULL OR v.request_status = @RequestStatus)
        AND (@RequesterType IS NULL OR v.requester_type = @RequesterType)
        AND (@RequestedFrom IS NULL OR v.requested_at >= @RequestedFrom)
        AND (@RequestedTo IS NULL OR v.requested_at < DATEADD(DAY, 1, @RequestedTo));

    SELECT
        v.*,
        @TotalCount AS total_count,
        ROW_NUMBER() OVER (ORDER BY v.requested_at DESC, v.created_at DESC) AS rn
    FROM dbo.vw_benefit_requests_admin_list v
    WHERE
        (@Search IS NULL
            OR v.benefit_title LIKE '%' + @Search + '%'
            OR v.partner_name LIKE '%' + @Search + '%'
            OR v.requester_name LIKE '%' + @Search + '%'
            OR v.pet_name LIKE '%' + @Search + '%')
        AND (@BenefitId IS NULL OR v.benefit_id = @BenefitId)
        AND (@PartnerId IS NULL OR v.partner_id = @PartnerId)
        AND (@RequestStatus IS NULL OR v.request_status = @RequestStatus)
        AND (@RequesterType IS NULL OR v.requester_type = @RequesterType)
        AND (@RequestedFrom IS NULL OR v.requested_at >= @RequestedFrom)
        AND (@RequestedTo IS NULL OR v.requested_at < DATEADD(DAY, 1, @RequestedTo))
    ORDER BY v.requested_at DESC, v.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY
    OPTION (RECOMPILE);
END
GO

