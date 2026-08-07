CREATE   PROCEDURE [dbo].[usp_partner_customers_admin_dashboard_summary]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_partner_customers_admin_summary;

    SELECT *
    FROM dbo.vw_partner_customers_conversion_funnel
    ORDER BY partner_name;
END
GO

