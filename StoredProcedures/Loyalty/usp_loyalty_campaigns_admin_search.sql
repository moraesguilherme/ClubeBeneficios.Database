CREATE   PROCEDURE [dbo].[usp_loyalty_campaigns_admin_search]
    @Search varchar(150) = NULL,
    @CampaignType varchar(50) = NULL,
    @Status varchar(30) = NULL,
    @AudienceType varchar(50) = NULL,
    @PageNumber int = 1,
    @PageSize int = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 20;

    ;WITH Filtered AS
    (
        SELECT
            c.id,
            c.name,
            c.description,
            c.campaign_type,
            c.status,
            c.starts_at,
            c.ends_at,
            c.audience_type,
            c.stacking_mode,
            c.created_at,
            c.updated_at,
            conditions_count =
            (
                SELECT COUNT(1)
                FROM dbo.loyalty_campaign_conditions cc
                WHERE cc.campaign_id = c.id
            )
        FROM dbo.loyalty_campaigns c
        WHERE (@Search IS NULL OR LTRIM(RTRIM(@Search)) = '' OR c.name LIKE '%' + @Search + '%' OR c.description LIKE '%' + @Search + '%')
          AND (@CampaignType IS NULL OR @CampaignType = '' OR c.campaign_type = @CampaignType)
          AND (@Status IS NULL OR @Status = '' OR c.status = @Status)
          AND (@AudienceType IS NULL OR @AudienceType = '' OR c.audience_type = @AudienceType)
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY updated_at DESC, starts_at DESC, name ASC)
        FROM Filtered
    )
    SELECT
        id,
        name,
        description,
        campaign_type,
        status,
        starts_at,
        ends_at,
        audience_type,
        stacking_mode,
        created_at,
        updated_at,
        conditions_count,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO


