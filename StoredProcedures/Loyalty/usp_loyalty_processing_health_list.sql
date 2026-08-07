CREATE   PROCEDURE [dbo].[usp_loyalty_processing_health_list]
    @ProcessingStatus varchar(30) = NULL,
    @ProcessingStage varchar(30) = NULL,
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
            l.id,
            l.import_row_id,
            l.client_id,
            c.full_name AS client_name,
            l.processing_stage,
            l.processing_status,
            l.message,
            l.loyalty_event_id,
            l.created_at
        FROM dbo.loyalty_processing_log l
        LEFT JOIN dbo.clients c
            ON c.id = l.client_id
        WHERE (@ProcessingStatus IS NULL OR @ProcessingStatus = '' OR l.processing_status = @ProcessingStatus)
          AND (@ProcessingStage IS NULL OR @ProcessingStage = '' OR l.processing_stage = @ProcessingStage)
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY created_at DESC)
        FROM Filtered
    )
    SELECT
        id,
        import_row_id,
        client_id,
        client_name,
        processing_stage,
        processing_status,
        message,
        loyalty_event_id,
        created_at,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO

