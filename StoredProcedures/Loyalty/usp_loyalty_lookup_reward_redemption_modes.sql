CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_reward_redemption_modes]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('manual_review',    'Revis�o manual',      1),
            ('auto_approve',     'Aprova��o autom�tica',2),
            ('approval_required', 'Aprova��o obrigat�ria', 3)
    ) AS x(redemption_mode_code, redemption_mode_name, display_order)
    ORDER BY x.display_order;
END
GO


