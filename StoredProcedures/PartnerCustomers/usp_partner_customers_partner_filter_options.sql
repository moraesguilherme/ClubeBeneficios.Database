CREATE   PROCEDURE [dbo].[usp_partner_customers_partner_filter_options]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.id,
        p.trade_name,
        p.status,
        p.segment,
        p.category
    FROM dbo.partners p
    WHERE EXISTS (
        SELECT 1
        FROM dbo.partner_customers pc
        WHERE pc.partner_id = p.id
    )
    ORDER BY p.trade_name;
END
GO

