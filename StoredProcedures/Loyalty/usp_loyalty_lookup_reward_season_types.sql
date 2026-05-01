CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_reward_season_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('low',    'Baixa temporada', 1),
            ('high',   'Alta temporada',  2),
            ('all',    'Todas',           3),
            ('custom', 'Personalizada',   4)
    ) AS x(season_type_code, season_type_name, display_order)
    ORDER BY x.display_order;
END
GO

