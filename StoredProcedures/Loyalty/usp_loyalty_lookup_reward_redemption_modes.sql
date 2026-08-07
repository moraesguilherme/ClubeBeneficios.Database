CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_reward_redemption_modes]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('approval_required', 'Aprovação obrigatória', 1),
            ('automatic',         'Automático',            2),
            ('manual_review',     'Revisão manual',        3)
    ) AS x(redemption_mode_code, redemption_mode_name, display_order)
    ORDER BY x.display_order;
END
GO

