
CREATE PROCEDURE [dbo].[usp_loyalty_event_exists_for_etl_row]
    @ImportRowId bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM dbo.customer_loyalty_events
                WHERE source_type = 'etl_payment_row'
                  AND source_id = CONVERT(varchar(100), @ImportRowId)
            )
            THEN CAST(1 AS bit)
            ELSE CAST(0 AS bit)
        END AS event_exists;
END

GO


