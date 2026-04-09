CREATE   PROCEDURE [dbo].[usp_benefit_requests_partner_filter_options]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        p.id,
        p.trade_name,
        p.status,
        p.segment,
        p.category
    FROM dbo.vw_benefit_requests_admin_list r
    INNER JOIN dbo.partners p
        ON p.id = r.partner_id
    ORDER BY p.trade_name;
END
GO


