CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_adjustment_impact_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('points',      'Pontos',         1),
            ('eligibility', 'Elegibilidade',  2),
            ('level',       'Nível',          3),
            ('metrics',     'Métricas',       4),
            ('mixed',       'Misto',          5),
            ('none',        'Sem impacto',    6)
    ) AS x(impact_type_code, impact_type_name, display_order)
    ORDER BY x.display_order;
END
GO

