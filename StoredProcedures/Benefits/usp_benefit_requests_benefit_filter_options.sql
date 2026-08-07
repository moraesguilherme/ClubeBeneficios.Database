CREATE   PROCEDURE [dbo].[usp_benefit_requests_benefit_filter_options]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        b.id,
        b.title,
        b.status,
        b.benefit_type,
        b.direction,
        b.partner_id
    FROM dbo.vw_benefit_requests_admin_list r
    INNER JOIN dbo.benefits b
        ON b.id = r.benefit_id
    ORDER BY b.title;
END
GO

