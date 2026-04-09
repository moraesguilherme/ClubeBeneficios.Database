CREATE   PROCEDURE [dbo].[usp_partner_customer_benefit_requests_list]
    @PartnerCustomerId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_benefit_requests_customer_list
    WHERE requester_type = 'partner_customer'
      AND requester_partner_customer_id = @PartnerCustomerId
    ORDER BY requested_at DESC, updated_at DESC;
END
GO


