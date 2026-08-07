CREATE   PROCEDURE [dbo].[usp_loyalty_level_threshold_admin_get]
    @LevelThresholdId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id,
        level_code,
        level_name,
        min_average_ticket_amount,
        max_average_ticket_amount,
        evaluation_window_months,
        downgrade_grace_months,
        display_order,
        status,
        created_at,
        updated_at,
        created_by_user_id,
        updated_by_user_id
    FROM dbo.loyalty_level_thresholds
    WHERE id = @LevelThresholdId;
END;
GO

