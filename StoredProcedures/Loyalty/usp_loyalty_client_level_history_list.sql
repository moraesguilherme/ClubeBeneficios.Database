CREATE   PROCEDURE [dbo].[usp_loyalty_client_level_history_list]
    @ClientId uniqueidentifier,
    @PageNumber int = 1,
    @PageSize int = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 20;

    ;WITH Numbered AS
    (
        SELECT
            h.id,
            h.client_id,
            h.from_level_code,
            h.to_level_code,
            h.change_reason,
            h.source_type,
            h.source_id,
            h.changed_at,
            h.created_at,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY h.changed_at DESC, h.created_at DESC)
        FROM dbo.loyalty_level_history h
        WHERE h.client_id = @ClientId
    )
    SELECT
        id,
        client_id,
        from_level_code,
        to_level_code,
        change_reason,
        source_type,
        source_id,
        changed_at,
        created_at,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO


