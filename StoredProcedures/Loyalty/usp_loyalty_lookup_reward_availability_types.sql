CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_reward_availability_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('general',   'Uso geral',        1),
            ('weekdays',  'Dias úteis',       2),
            ('weekend',   'Fim de semana',    3),
            ('date_range','Período específico',4),
            ('custom',    'Personalizado',    5)
    ) AS x(availability_type_code, availability_type_name, display_order)
    ORDER BY x.display_order;
END
GO

