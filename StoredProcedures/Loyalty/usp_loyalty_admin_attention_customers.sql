CREATE   PROCEDURE [dbo].[usp_loyalty_admin_attention_customers]
    @Top int = 20
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH LatestScore AS
    (
        SELECT
            s.client_id,
            s.score_value,
            s.level_code,
            s.trend_code,
            s.trend_reason,
            s.low_redemption_flag,
            s.downgrade_risk_flag,
            s.upgrade_distance,
            s.calculated_at,
            ROW_NUMBER() OVER (PARTITION BY s.client_id ORDER BY s.calculated_at DESC, s.created_at DESC) AS rn
        FROM dbo.loyalty_score_snapshots s
    )
    SELECT TOP (@Top)
        c.id AS client_id,
        c.full_name AS client_name,
        s.level_code,
        s.score_value,
        status_label =
            CASE
                WHEN s.downgrade_risk_flag = 1 THEN 'Risco de downgrade'
                WHEN s.trend_code = 'upgrade' THEN 'Pr�ximo de upgrade'
                WHEN s.low_redemption_flag = 1 THEN 'Baixo uso do programa'
                ELSE 'Aten��o'
            END,
        reason =
            CASE
                WHEN s.downgrade_risk_flag = 1 THEN ISNULL(s.trend_reason, 'Cliente com risco de downgrade.')
                WHEN s.trend_code = 'upgrade' THEN ISNULL(s.trend_reason, 'Cliente pr�ximo de upgrade.')
                WHEN s.low_redemption_flag = 1 THEN ISNULL(s.trend_reason, 'Cliente com baixo uso do programa.')
                ELSE ISNULL(s.trend_reason, 'Cliente requer acompanhamento.')
            END,
        s.calculated_at
    FROM LatestScore s
    INNER JOIN dbo.clients c
        ON c.id = s.client_id
    WHERE s.rn = 1
      AND (
            s.downgrade_risk_flag = 1
         OR s.trend_code = 'upgrade'
         OR s.low_redemption_flag = 1
      )
    ORDER BY
        CASE
            WHEN s.downgrade_risk_flag = 1 THEN 1
            WHEN s.trend_code = 'upgrade' THEN 2
            WHEN s.low_redemption_flag = 1 THEN 3
            ELSE 4
        END,
        s.score_value DESC;
END
GO


