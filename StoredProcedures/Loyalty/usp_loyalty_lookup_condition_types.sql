CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_condition_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('paid_amount',     'Valor pago',              1),
            ('payment_method',  'Forma de pagamento',      2),
            ('service_type',    'Tipo de serviço',         3),
            ('plan_type',       'Plano contratado',        4),
            ('package_type',    'Pacote contratado',       5),
            ('level_gate',      'Nível do cliente',        6),
            ('client_birthday', 'Aniversário do tutor',    7),
            ('pet_birthday',    'Aniversário do cão',      8),
            ('pet_created',     'Novo cão cadastrado',     9),
            ('referral',        'Indicação',              10),
            ('campaign',        'Campanha',               11),
            ('custom',          'Personalizada',          12)
    ) AS x(condition_type_code, condition_type_name, display_order)
    ORDER BY x.display_order;
END
GO

