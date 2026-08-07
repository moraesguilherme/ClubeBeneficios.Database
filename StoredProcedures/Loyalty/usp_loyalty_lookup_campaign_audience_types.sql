CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_campaign_audience_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('clients',     'Clientes elegíveis', 1),
            ('all_clients', 'Todos os clientes',  2),
            ('custom',      'Personalizado',      3)
    ) AS x(audience_type_code, audience_type_name, display_order)
    ORDER BY x.display_order;
END
GO

