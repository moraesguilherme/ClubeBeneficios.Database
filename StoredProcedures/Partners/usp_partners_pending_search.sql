CREATE   PROCEDURE [dbo].[usp_partners_pending_search]
    @Search         VARCHAR(150) = NULL,
    @Category       VARCHAR(120) = NULL,
    @Segment        VARCHAR(120) = NULL,
    @SortBy         VARCHAR(50)  = 'created_at',
    @SortDirection  VARCHAR(4)   = 'desc',
    @Page           INT          = 1,
    @PageSize       INT          = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @Page < 1 SET @Page = 1;
    IF @PageSize < 1 SET @PageSize = 20;
    IF @PageSize > 200 SET @PageSize = 200;

    SET @SortBy = LOWER(ISNULL(@SortBy, 'created_at'));
    SET @SortDirection = LOWER(ISNULL(@SortDirection, 'desc'));

    ;WITH filtered AS
    (
        SELECT
            v.*,
            COUNT(1) OVER() AS total_count
        FROM dbo.vw_partners_admin_list v
        WHERE
            v.status IN ('pending_review', 'under_review')
            AND (
                @Search IS NULL
                OR LTRIM(RTRIM(@Search)) = ''
                OR v.trade_name        LIKE '%' + @Search + '%'
                OR v.legal_name        LIKE '%' + @Search + '%'
                OR v.document          LIKE '%' + @Search + '%'
                OR v.email             LIKE '%' + @Search + '%'
                OR v.segment           LIKE '%' + @Search + '%'
                OR v.category          LIKE '%' + @Search + '%'
                OR v.service_region    LIKE '%' + @Search + '%'
                OR v.responsible_name  LIKE '%' + @Search + '%'
                OR v.responsible_email LIKE '%' + @Search + '%'
            )
            AND (@Category IS NULL OR @Category = '' OR v.category = @Category)
            AND (@Segment IS NULL OR @Segment = '' OR v.segment = @Segment)
    )
    SELECT
        id,
        trade_name,
        legal_name,
        document,
        email,
        phone,
        status,
        logo_url,
        segment,
        category,
        service_region,
        website,
        instagram,
        description,
        level,
        indication_flow_enabled,
        access_code_flow_enabled,
        origin_type,
        created_at,
        updated_at,
        approved_at,
        rejected_at,
        inactivated_at,
        created_by_user_id,
        approved_by_user_id,
        rejected_by_user_id,
        responsible_name,
        responsible_role,
        responsible_email,
        responsible_phone,
        benefits_count,
        converted_clients_count,
        campaigns_count,
        raffles_count,
        performance_score,
        metrics_refreshed_at,
        total_count
    FROM filtered
    ORDER BY
        CASE WHEN @SortBy = 'trade_name' AND @SortDirection = 'asc' THEN trade_name END ASC,
        CASE WHEN @SortBy = 'trade_name' AND @SortDirection = 'desc' THEN trade_name END DESC,
        CASE WHEN @SortBy = 'category' AND @SortDirection = 'asc' THEN category END ASC,
        CASE WHEN @SortBy = 'category' AND @SortDirection = 'desc' THEN category END DESC,
        CASE WHEN @SortBy = 'segment' AND @SortDirection = 'asc' THEN segment END ASC,
        CASE WHEN @SortBy = 'segment' AND @SortDirection = 'desc' THEN segment END DESC,
        CASE WHEN @SortBy = 'created_at' AND @SortDirection = 'asc' THEN created_at END ASC,
        CASE WHEN @SortBy = 'created_at' AND @SortDirection = 'desc' THEN created_at END DESC,
        created_at DESC
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

