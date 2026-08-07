CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_rule_calculation_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('fixed_points', 'Pontos fixos',         1),
            ('per_currency', 'Por valor monetário',  2),
            ('multiplier',   'Multiplicador',        3),
            ('formula',      'Fórmula',              4),
            ('manual_only',  'Manual',               5)
    ) AS x(calculation_type_code, calculation_type_name, display_order)
    ORDER BY x.display_order;
END
GO

