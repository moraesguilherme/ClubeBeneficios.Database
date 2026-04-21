CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_adjustment_statuses]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('pending',  'Pendente',  1),
            ('approved', 'Aprovado',  2),
            ('rejected', 'Rejeitado', 3),
            ('canceled', 'Cancelado', 4)
    ) AS x(status_code, status_name, display_order)
    ORDER BY x.display_order;
END
GO


