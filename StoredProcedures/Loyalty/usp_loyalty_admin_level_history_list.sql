CREATE   PROCEDURE [dbo].[usp_loyalty_admin_level_history_list]
    @Search varchar(150) = NULL,
    @LevelCode varchar(30) = NULL,
    @DateFrom datetime2(7) = NULL,
    @DateTo datetime2(7) = NULL,
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
            h.id,
            h.client_id,
            c.full_name AS client_name,
            h.from_level_code,
            h.to_level_code,
            h.change_reason,
            h.source_type,
            h.source_id,
            h.changed_at
        FROM dbo.loyalty_level_history h
        INNER JOIN dbo.clients c
            ON c.id = h.client_id
        WHERE (@Search IS NULL OR LTRIM(RTRIM(@Search)) = '' OR c.full_name LIKE '%' + @Search + '%')
          AND (@LevelCode IS NULL OR @LevelCode = '' OR h.to_level_code = @LevelCode)
          AND (@DateFrom IS NULL OR h.changed_at >= @DateFrom)
          AND (@DateTo IS NULL OR h.changed_at < @DateTo)
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY changed_at DESC)
        FROM Filtered
    )
    SELECT
        id,
        client_id,
        client_name,
        from_level_code,
        to_level_code,
        change_reason,
        source_type,
        source_id,
        changed_at,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO


