CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_reward_season_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('all',         'Todas',           1),
            ('low_season',  'Baixa temporada', 2),
            ('high_season', 'Alta temporada',  3),
            ('holiday',     'Feriados',        4)
    ) AS x(season_type_code, season_type_name, display_order)
    ORDER BY x.display_order;
END
GO

