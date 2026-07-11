CREATE   PROCEDURE [dbo].[usp_loyalty_redemption_full_get]
    @RedemptionId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH LatestLevel AS
    (
        SELECT
            h.client_id,
            h.to_level_code,
            ROW_NUMBER() OVER (
                PARTITION BY h.client_id
                ORDER BY h.changed_at DESC, h.created_at DESC
            ) AS rn
        FROM dbo.loyalty_level_history h
    )
    SELECT
        r.id AS redemption_id,
        r.client_id,
        c.full_name AS client_name,
        r.reward_id,
        rw.title AS reward_title,
        rw.description AS reward_description,
        ISNULL(ll.to_level_code, rw.eligible_level_code) AS level_code,

        r.redemption_code,
        r.requested_points_cost,
        r.approved_points_cost,
        r.status,
        r.request_channel,

        rw.redemption_mode,
        rw.usage_window_type,
        rw.usage_window_value,
        rw.availability_type AS reward_type,
        rw.season_type,
        rw.minimum_notice_hours,
        rw.cumulative_mode,
        rw.is_transferable,

        r.requested_at,
        r.approved_at,
        r.rejected_at,
        r.canceled_at,
        r.scheduled_for,
        r.used_at,
        r.completed_at,
        r.expires_at,

        r.notes,
        r.internal_notes,
        r.requested_by_user_id,
        r.decided_by_user_id,
        r.created_at,
        r.updated_at
    FROM dbo.loyalty_redemptions r
    INNER JOIN dbo.clients c
        ON c.id = r.client_id
    INNER JOIN dbo.loyalty_rewards rw
        ON rw.id = r.reward_id
    LEFT JOIN LatestLevel ll
        ON ll.client_id = r.client_id
       AND ll.rn = 1
    WHERE r.id = @RedemptionId;
END
GO

