CREATE   PROCEDURE [dbo].[usp_clients_admin_search_paged]
    @Search VARCHAR(150) = NULL,
    @Status VARCHAR(30) = NULL,
    @OriginType VARCHAR(30) = NULL,
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
            c.*,
            ROW_NUMBER() OVER (
                ORDER BY c.created_at DESC, c.full_name ASC
            ) AS rn,
            COUNT(1) OVER() AS total_count
        FROM dbo.clients c
        WHERE
            (@Search IS NULL OR
                c.full_name LIKE '%' + @Search + '%'
                OR c.email LIKE '%' + @Search + '%'
                OR c.phone LIKE '%' + @Search + '%'
                OR c.document LIKE '%' + @Search + '%')
            AND (@Status IS NULL OR c.status = @Status)
            AND (@OriginType IS NULL OR c.origin_type = @OriginType)
    )
    SELECT *
    FROM base
    WHERE rn BETWEEN ((@PageNumber - 1) * @PageSize) + 1
                AND (@PageNumber * @PageSize)
    ORDER BY rn;
END
GO


