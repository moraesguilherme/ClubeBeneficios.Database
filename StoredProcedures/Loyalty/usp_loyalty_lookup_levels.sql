CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_levels]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('bronze',   'Bronze',   1),
            ('silver',   'Prata',    2),
            ('gold',     'Ouro',     3),
            ('diamond',  'Diamante', 4)
    ) AS x(level_code, level_name, display_order)
    ORDER BY x.display_order;
END
GO

