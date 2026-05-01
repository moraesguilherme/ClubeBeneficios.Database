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
            ('credit_card',   'Cartão de crédito',     3),
            ('debit_card',    'Cartão de débito',      4),
            ('bank_transfer', 'Transferência',         5),
            ('boleto',        'Boleto',                6),
            ('other',         'Outro',                 7)
    ) AS x(payment_method_code, payment_method_name, display_order)
    ORDER BY x.display_order;
END
GO

