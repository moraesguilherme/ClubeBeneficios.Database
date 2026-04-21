CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_payment_methods]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('pix',           'PIX',                   1),
            ('cash',          'Dinheiro',              2),
            ('credit_card',   'Cart�o de cr�dito',     3),
            ('debit_card',    'Cart�o de d�bito',      4),
            ('bank_transfer', 'Transfer�ncia',         5),
            ('boleto',        'Boleto',                6),
            ('other',         'Outro',                 7)
    ) AS x(payment_method_code, payment_method_name, display_order)
    ORDER BY x.display_order;
END
GO


