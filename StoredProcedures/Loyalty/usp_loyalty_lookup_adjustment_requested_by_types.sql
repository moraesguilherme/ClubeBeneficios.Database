CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_adjustment_requested_by_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('admin',     'Admin',     1),
            ('operation', 'Operação',  2),
            ('system',    'Sistema',   3),
            ('client',    'Cliente',   4),
            ('internal',  'Interno',   5)
    ) AS x(requested_by_type_code, requested_by_type_name, display_order)
    ORDER BY x.display_order;
END
GO

