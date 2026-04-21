CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_reward_usage_window_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('day',      'Dia',       1),
            ('week',     'Semana',    2),
            ('month',    'M�s',       3),
            ('quarter',  'Trimestre', 4),
            ('semester', 'Semestre',  5),
            ('year',     'Ano',       6)
    ) AS x(window_type_code, window_type_name, display_order)
    ORDER BY x.display_order;
END
GO


