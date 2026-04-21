CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_rule_stacking_modes]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('stackable',    'Cumulativa',          1),
            ('highest_only', 'Maior valor apenas',  2),
            ('exclusive',    'Exclusiva',           3)
    ) AS x(stacking_mode_code, stacking_mode_name, display_order)
    ORDER BY x.display_order;
END
GO


