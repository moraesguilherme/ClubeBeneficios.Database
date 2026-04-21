CREATE   PROCEDURE [dbo].[usp_loyalty_admin_level_distribution]
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH LatestScore AS
    (
        SELECT
            s.client_id,
            s.level_code,
            ROW_NUMBER() OVER (PARTITION BY s.client_id ORDER BY s.calculated_at DESC, s.created_at DESC) AS rn
        FROM dbo.loyalty_score_snapshots s
    ),
    LevelCounts AS
    (
        SELECT
            s.level_code,
            COUNT(*) AS total_clients
        FROM LatestScore s
        WHERE s.rn = 1
        GROUP BY s.level_code
    ),
    Totals AS
    (
        SELECT SUM(total_clients) AS grand_total
        FROM LevelCounts
    )
    SELECT
        lc.level_code,
        lc.total_clients,
        percentage = CAST(
            CASE
                WHEN t.grand_total IS NULL OR t.grand_total = 0 THEN 0
                ELSE (lc.total_clients * 100.0 / t.grand_total)
            END
            AS decimal(10,2)
        )
    FROM LevelCounts lc
    CROSS JOIN Totals t
    ORDER BY
        CASE lc.level_code
            WHEN 'diamond' THEN 4
            WHEN 'gold' THEN 3
            WHEN 'silver' THEN 2
            WHEN 'bronze' THEN 1
            ELSE 0
        END DESC;
END
GO


