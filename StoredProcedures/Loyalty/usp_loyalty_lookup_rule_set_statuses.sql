CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_rule_set_statuses]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('draft',     'Rascunho',     1),
            ('scheduled', 'Programada',   2),
            ('active',    'Ativa',        3),
            ('inactive',  'Inativa',      4),
            ('archived',  'Arquivada',    5)
    ) AS x(status_code, status_name, display_order)
    ORDER BY x.display_order;
END
GO


