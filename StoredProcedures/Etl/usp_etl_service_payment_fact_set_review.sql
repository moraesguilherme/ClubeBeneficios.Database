CREATE PROCEDURE [dbo].[usp_etl_service_payment_fact_set_review]
    @Id                 bigint,
    @ReviewRequired     bit,
    @MatchConfidence    decimal(5,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.etl_service_payment_facts
       SET review_required = @ReviewRequired,
           match_confidence = COALESCE(@MatchConfidence, match_confidence),
           updated_at = SYSUTCDATETIME()
     WHERE id = @Id;
END
GO
