CREATE   PROCEDURE [dbo].[usp_loyalty_admin_health_summary]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        last_financial_sync_at =
        (
            SELECT MAX(e.created_at)
            FROM dbo.customer_loyalty_events e
            WHERE e.source_type = 'etl_payment_row'
        ),
        pending_processing_events =
        (
            SELECT COUNT(1)
            FROM dbo.loyalty_processing_log l
            WHERE l.processing_status = 'pending'
        ),
        inconsistencies_detected =
        (
            SELECT COUNT(1)
            FROM dbo.loyalty_processing_log l
            WHERE l.processing_status = 'inconsistent'
        ),
        pending_adjustments =
        (
            SELECT COUNT(1)
            FROM dbo.loyalty_adjustments a
            WHERE a.status = 'pending'
        );
END
GO


