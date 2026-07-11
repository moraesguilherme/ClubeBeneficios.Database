CREATE   PROCEDURE [dbo].[usp_benefit_usages_admin_search_paged]
    @Search VARCHAR(150) = NULL,
    @UsedByType VARCHAR(30) = NULL,
    @UsageStatus VARCHAR(30) = NULL,
    @PartnerId UNIQUEIDENTIFIER = NULL,
    @BenefitId UNIQUEIDENTIFIER = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 20;
    IF @PageSize > 200 SET @PageSize = 200;

    ;WITH base AS
    (
        SELECT
            v.*,
            ROW_NUMBER() OVER (
                ORDER BY v.used_at DESC, v.created_at DESC
            ) AS rn,
            COUNT(1) OVER() AS total_count
        FROM dbo.vw_benefit_usage_overview v
        WHERE
            (@Search IS NULL OR
                v.snapshot_title LIKE '%' + @Search + '%'
                OR v.partner_name LIKE '%' + @Search + '%'
                OR v.used_by_name LIKE '%' + @Search + '%'
                OR v.pet_name LIKE '%' + @Search + '%')
            AND (@UsedByType IS NULL OR v.used_by_type = @UsedByType)
            AND (@UsageStatus IS NULL OR v.usage_status = @UsageStatus)
            AND (@PartnerId IS NULL OR v.partner_id = @PartnerId)
            AND (@BenefitId IS NULL OR v.benefit_id = @BenefitId)
    )
    SELECT *
    FROM base
    WHERE rn BETWEEN ((@PageNumber - 1) * @PageSize) + 1
                AND (@PageNumber * @PageSize)
    ORDER BY rn;
END
GO

