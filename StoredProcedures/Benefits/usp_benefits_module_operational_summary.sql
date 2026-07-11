CREATE   PROCEDURE [dbo].[usp_benefits_module_operational_summary]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        (SELECT COUNT(1) FROM dbo.benefit_requests) AS total_requests,
        (SELECT COUNT(1) FROM dbo.benefit_requests WHERE approval_status = 'pending_review') AS pending_approval_requests,
        (SELECT COUNT(1) FROM dbo.benefit_requests WHERE approval_status = 'under_review') AS under_review_requests,
        (SELECT COUNT(1) FROM dbo.benefit_requests WHERE request_status = 'approved') AS approved_requests,
        (SELECT COUNT(1) FROM dbo.benefit_requests WHERE request_status = 'declined') AS declined_requests,
        (SELECT COUNT(1) FROM dbo.benefit_requests WHERE request_status = 'converted_to_usage') AS converted_to_usage_requests,
        (SELECT COUNT(1) FROM dbo.benefit_usages) AS total_usages,
        (SELECT COUNT(1) FROM dbo.clients) AS total_clients,
        (SELECT COUNT(1) FROM dbo.partner_customers) AS total_partner_customers;
END
GO

