CREATE   PROCEDURE [dbo].[usp_loyalty_adjustment_full_get]
    @AdjustmentId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.*,
        c.full_name AS client_name
    FROM dbo.loyalty_adjustments a
    INNER JOIN dbo.clients c ON c.id = a.client_id
    WHERE a.id = @AdjustmentId;
END
GO


