CREATE   PROCEDURE [dbo].[usp_benefit_usages_admin_search]
    @Search VARCHAR(150) = NULL,
    @UsedByType VARCHAR(30) = NULL,
    @UsageStatus VARCHAR(30) = NULL,
    @PartnerId UNIQUEIDENTIFIER = NULL,
    @BenefitId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.*
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
    ORDER BY v.used_at DESC, v.created_at DESC;
END
GO

