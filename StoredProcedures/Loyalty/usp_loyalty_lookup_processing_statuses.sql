CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_processing_statuses]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('pending',      'Pendente',        1),
            ('processed',    'Processado',      2),
            ('ignored',      'Ignorado',        3),
            ('failed',       'Falhou',          4),
            ('inconsistent', 'Inconsistente',   5)
    ) AS x(status_code, status_name, display_order)
    ORDER BY x.display_order;
END
GO

