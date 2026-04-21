CREATE   PROCEDURE [dbo].[usp_loyalty_admin_reclassification_candidates]
    @Top int = 20
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH LatestScore AS
    (
        SELECT
            s.client_id,
            s.level_code,
            s.trend_code,
            s.trend_reason,
            s.upgrade_distance,
            s.downgrade_risk_flag,
            s.calculated_at,
            ROW_NUMBER() OVER (PARTITION BY s.client_id ORDER BY s.calculated_at DESC, s.created_at DESC) AS rn
        FROM dbo.loyalty_score_snapshots s
    )
    SELECT TOP (@Top)
        c.id AS client_id,
        c.full_name AS client_name,
        current_level_code = s.level_code,
        target_level_code =
            CASE
                WHEN s.trend_code = 'upgrade' AND s.level_code = 'bronze' THEN 'silver'
                WHEN s.trend_code = 'upgrade' AND s.level_code = 'silver' THEN 'gold'
                WHEN s.trend_code = 'upgrade' AND s.level_code = 'gold' THEN 'diamond'
                WHEN s.downgrade_risk_flag = 1 AND s.level_code = 'diamond' THEN 'gold'
                WHEN s.downgrade_risk_flag = 1 AND s.level_code = 'gold' THEN 'silver'
                WHEN s.downgrade_risk_flag = 1 AND s.level_code = 'silver' THEN 'bronze'
                ELSE s.level_code
            END,
        detail = ISNULL(s.trend_reason, 'Reclassificacao sugerida pelo score.'),
        s.calculated_at
    FROM LatestScore s
    INNER JOIN dbo.clients c
        ON c.id = s.client_id
    WHERE s.rn = 1
      AND (
            s.trend_code = 'upgrade'
         OR s.downgrade_risk_flag = 1
      )
    ORDER BY
        CASE
            WHEN s.trend_code = 'upgrade' THEN 1
            WHEN s.downgrade_risk_flag = 1 THEN 2
            ELSE 3
        END,
        s.calculated_at DESC;
END
GO


