CREATE PROCEDURE [dbo].[usp_etl_service_payment_fact_set_loyalty_status]
    @Id                     bigint,
    @ReadyForLoyalty        bit = NULL,
    @LoyaltyEventGenerated  bit = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.etl_service_payment_facts
       SET ready_for_loyalty =
            COALESCE(@ReadyForLoyalty, ready_for_loyalty),
           loyalty_event_generated =
            COALESCE(@LoyaltyEventGenerated, loyalty_event_generated),
           updated_at = SYSUTCDATETIME()
     WHERE id = @Id;
END
GO
