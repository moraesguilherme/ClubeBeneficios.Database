CREATE   PROCEDURE [dbo].[usp_partner_customer_benefit_dashboard_summary]
    @PartnerCustomerId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_partner_customer_benefit_dashboard_summary
    WHERE partner_customer_id = @PartnerCustomerId;

    SELECT TOP (5)
        id,
        benefit_id,
        benefit_title,
        partner_id,
        partner_name,
        request_status,
        approval_status,
        pet_name,
        requested_at,
        updated_at
    FROM dbo.vw_benefit_requests_customer_list
    WHERE requester_type = 'partner_customer'
      AND requester_partner_customer_id = @PartnerCustomerId
    ORDER BY requested_at DESC, updated_at DESC;
END
GO

