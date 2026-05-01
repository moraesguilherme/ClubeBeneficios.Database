CREATE   PROCEDURE [dbo].[usp_loyalty_event_exists_for_source]
    @ClientId uniqueidentifier,
    @SourceType varchar(50),
    @SourceId varchar(100),
    @SourceReference varchar(150) = NULL,
    @RuleId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM dbo.customer_loyalty_events e
                WHERE e.client_id = @ClientId
                  AND e.source_type = @SourceType
                  AND e.source_id = @SourceId
                  AND ISNULL(e.source_reference, '') = ISNULL(@SourceReference, '')
                  AND (
                        @RuleId IS NULL
                        OR e.rule_id = @RuleId
                      )
            )
            THEN CAST(1 AS bit)
            ELSE CAST(0 AS bit)
        END AS event_exists;
END;
GO

