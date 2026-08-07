CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_rule_categories]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('scoring',        'Pontuação',     1),
            ('level',          'Níveis',        2),
            ('redemption',     'Resgate',       3),
            ('usage',          'Utilização',    4),
            ('eligibility',    'Elegibilidade', 5),
            ('campaign_bonus', 'Campanha',      6)
    ) AS x(category_code, category_name, display_order)
    ORDER BY x.display_order;
END
GO

