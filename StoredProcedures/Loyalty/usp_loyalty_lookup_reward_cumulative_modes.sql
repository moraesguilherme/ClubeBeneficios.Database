CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_reward_cumulative_modes]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('non_cumulative', 'Não cumulativa', 1),
            ('cumulative',     'Cumulativa',     2)
    ) AS x(cumulative_mode_code, cumulative_mode_name, display_order)
    ORDER BY x.display_order;
END
GO

