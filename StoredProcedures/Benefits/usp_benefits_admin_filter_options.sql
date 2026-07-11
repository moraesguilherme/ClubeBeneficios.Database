CREATE   PROCEDURE [dbo].[usp_benefits_admin_filter_options]
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.usp_benefits_filter_options;

    SELECT
        'partners' AS bucket,
        CONVERT(VARCHAR(36), p.id) AS value,
        p.trade_name AS label,
        p.status,
        p.segment,
        p.category,
        p.level,
        ROW_NUMBER() OVER (ORDER BY p.trade_name) AS sort_order
    FROM dbo.partners p
    WHERE p.status IN (
        'approved',
        'active',
        'under_review',
        'pending_review'
    )
    ORDER BY p.trade_name;
END
GO

