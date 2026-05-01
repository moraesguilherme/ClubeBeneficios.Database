CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_adjustment_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('points_correction',   'Correção de pontos',      1),
            ('redemption_reversal', 'Reversão de resgate',     2),
            ('eligibility_override','Override de elegibilidade',3),
            ('downgrade_review',    'Revisão de downgrade',    4),
            ('manual_credit',       'Crédito manual',          5),
            ('manual_debit',        'Débito manual',           6),
            ('custom',              'Personalizado',           7)
    ) AS x(adjustment_type_code, adjustment_type_name, display_order)
    ORDER BY x.display_order;
END
GO

