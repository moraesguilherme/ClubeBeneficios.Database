CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_campaign_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('signup',      'Cadastro',         1),
            ('referral',    'Indica��o',        2),
            ('anniversary', 'Anivers�rio',      3),
            ('seasonal',    'Sazonal',          4),
            ('fixed_bonus', 'B�nus fixo',       5),
            ('multiplier',  'Multiplicador',    6),
            ('custom',      'Personalizada',    7)
    ) AS x(campaign_type_code, campaign_type_name, display_order)
    ORDER BY x.display_order;
END
GO


