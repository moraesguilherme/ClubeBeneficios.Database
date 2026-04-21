CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_redemption_statuses]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('requested',    'Solicitado',   1),
            ('under_review', 'Em an�lise',   2),
            ('approved',     'Aprovado',     3),
            ('rejected',     'Rejeitado',    4),
            ('canceled',     'Cancelado',    5),
            ('used',         'Utilizado',    6),
            ('completed',    'Conclu�do',    7),
            ('expired',      'Expirado',     8)
    ) AS x(status_code, status_name, display_order)
    ORDER BY x.display_order;
END
GO


