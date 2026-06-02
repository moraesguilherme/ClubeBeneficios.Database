CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_reward_availability_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('general',  'Geral',    1),
            ('limited',  'Limitada', 2),
            ('seasonal', 'Sazonal',  3)
    ) AS x(availability_type_code, availability_type_name, display_order)
    ORDER BY x.display_order;
END
GO

