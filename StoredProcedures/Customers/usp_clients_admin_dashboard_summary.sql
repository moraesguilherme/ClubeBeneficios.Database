CREATE   PROCEDURE [dbo].[usp_clients_admin_dashboard_summary]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_clients_admin_summary;
END
GO

