CREATE   PROCEDURE [dbo].[usp_partner_customers_admin_search_paged]
    @Search VARCHAR(150) = NULL,
    @PartnerId UNIQUEIDENTIFIER = NULL,
    @Status VARCHAR(30) = NULL,
    @RegistrationStage VARCHAR(30) = NULL,
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
            pc.id,
            pc.user_id,
            pc.partner_id,
            p.trade_name AS partner_name,
            pc.access_code_id,
            pc.full_name,
            pc.email,
            pc.phone,
            pc.document,
            pc.birth_date,
            pc.origin_type,
            pc.origin_channel,
            pc.registration_stage,
            pc.status,
            pc.benefits_dashboard_unlocked_at,
            pc.converted_to_full_registration_at,
            pc.first_access_at,
            pc.last_access_at,
            pc.created_at,
            pc.updated_at,
            ROW_NUMBER() OVER (
                ORDER BY pc.created_at DESC, pc.full_name ASC
            ) AS rn,
            COUNT(1) OVER() AS total_count
        FROM dbo.partner_customers pc
        INNER JOIN dbo.partners p
            ON p.id = pc.partner_id
        WHERE
            (@Search IS NULL OR
                pc.full_name LIKE '%' + @Search + '%'
                OR pc.email LIKE '%' + @Search + '%'
                OR pc.phone LIKE '%' + @Search + '%'
                OR pc.document LIKE '%' + @Search + '%'
                OR p.trade_name LIKE '%' + @Search + '%')
            AND (@PartnerId IS NULL OR pc.partner_id = @PartnerId)
            AND (@Status IS NULL OR pc.status = @Status)
            AND (@RegistrationStage IS NULL OR pc.registration_stage = @RegistrationStage)
    )
    SELECT *
    FROM base
    WHERE rn BETWEEN ((@PageNumber - 1) * @PageSize) + 1
                AND (@PageNumber * @PageSize)
    ORDER BY rn;
END
GO


