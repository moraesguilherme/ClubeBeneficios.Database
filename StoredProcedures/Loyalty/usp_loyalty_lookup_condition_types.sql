CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_condition_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('service',      'Servi�o',          1),
            ('payment',      'Pagamento',        2),
            ('level_gate',   'N�vel',            3),
            ('signup',       'Cadastro',         4),
            ('anniversary',  'Anivers�rio',      5),
            ('referral',     'Indica��o',        6),
            ('campaign',     'Campanha',         7),
            ('custom',       'Personalizada',    8)
    ) AS x(condition_type_code, condition_type_name, display_order)
    ORDER BY x.display_order;
END
GO


