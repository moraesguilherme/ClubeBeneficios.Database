CREATE PROCEDURE [dbo].[usp_etl_service_payment_fact_set_match]
    @Id                 bigint,
    @ClientId           uniqueidentifier = NULL,
    @ClientPetId        uniqueidentifier = NULL,
    @PartnerId          uniqueidentifier = NULL,
    @MatchConfidence    decimal(5,2) = NULL,
    @ReviewRequired     bit = 0,
    @ReadyForLoyalty    bit = 0
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.etl_service_payment_facts
       SET client_id = @ClientId,
           client_pet_id = @ClientPetId,
           partner_id = @PartnerId,
           match_confidence = @MatchConfidence,
           review_required = @ReviewRequired,
           ready_for_loyalty = @ReadyForLoyalty,
           updated_at = SYSUTCDATETIME()
     WHERE id = @Id;
END
GO