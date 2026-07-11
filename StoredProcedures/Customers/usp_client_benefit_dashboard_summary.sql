CREATE   PROCEDURE [dbo].[usp_client_benefit_dashboard_summary]
    @ClientId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_client_benefit_dashboard_summary
    WHERE client_id = @ClientId;

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
    WHERE requester_type = 'client'
      AND requester_client_id = @ClientId
    ORDER BY requested_at DESC, updated_at DESC;
END
GO

