CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_score_trend_codes]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('upgrade',   'Pr�ximo de upgrade', 1),
            ('stable',    'Est�vel',            2),
            ('downgrade', 'Risco de downgrade', 3)
    ) AS x(trend_code, trend_name, display_order)
    ORDER BY x.display_order;
END
GO


