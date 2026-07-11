CREATE   PROCEDURE [dbo].[usp_client_benefit_requests_list]
    @ClientId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_benefit_requests_customer_list
    WHERE requester_type = 'client'
      AND requester_client_id = @ClientId
    ORDER BY requested_at DESC, updated_at DESC;
END
GO

