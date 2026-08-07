CREATE   PROCEDURE [dbo].[usp_loyalty_operational_sync_scheduled_entities]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now datetime2(7) = SYSUTCDATETIME();

    /* Rule sets */
    UPDATE dbo.loyalty_rule_sets
    SET
        status = 'active',
        updated_at = @Now
    WHERE status = 'scheduled'
      AND valid_from IS NOT NULL
      AND valid_from <= @Now
      AND (valid_to IS NULL OR valid_to > @Now);

    UPDATE dbo.loyalty_rule_sets
    SET
        status = 'inactive',
        updated_at = @Now
    WHERE status = 'active'
      AND valid_to IS NOT NULL
      AND valid_to <= @Now;

    /* Rules */
    UPDATE dbo.loyalty_rules
    SET
        status = 'active',
        updated_at = @Now
    WHERE status = 'scheduled'
      AND valid_from IS NOT NULL
      AND valid_from <= @Now
      AND (valid_to IS NULL OR valid_to > @Now);

    UPDATE dbo.loyalty_rules
    SET
        status = 'inactive',
        updated_at = @Now
    WHERE status = 'active'
      AND valid_to IS NOT NULL
      AND valid_to <= @Now;

    /* Campaigns */
    UPDATE dbo.loyalty_campaigns
    SET
        status = 'active',
        updated_at = @Now
    WHERE status = 'scheduled'
      AND starts_at <= @Now
      AND (ends_at IS NULL OR ends_at > @Now);

    UPDATE dbo.loyalty_campaigns
    SET
        status = 'inactive',
        updated_at = @Now
    WHERE status = 'active'
      AND ends_at IS NOT NULL
      AND ends_at <= @Now;

    /* Rewards */
    UPDATE dbo.loyalty_rewards
    SET
        status = 'active',
        updated_at = @Now
    WHERE status = 'scheduled';

    /* Level benefits */
    UPDATE dbo.loyalty_level_benefits
    SET
        status = 'active',
        updated_at = @Now
    WHERE status = 'scheduled'
      AND valid_from IS NOT NULL
      AND valid_from <= @Now
      AND (valid_to IS NULL OR valid_to > @Now);

    UPDATE dbo.loyalty_level_benefits
    SET
        status = 'inactive',
        updated_at = @Now
    WHERE status = 'active'
      AND valid_to IS NOT NULL
      AND valid_to <= @Now;

    SELECT
        rule_sets_activated =
        (
            SELECT COUNT(1)
            FROM dbo.loyalty_rule_sets
            WHERE status = 'active'
              AND valid_from IS NOT NULL
              AND valid_from <= @Now
        ),
        rules_activated =
        (
            SELECT COUNT(1)
            FROM dbo.loyalty_rules
            WHERE status = 'active'
              AND valid_from IS NOT NULL
              AND valid_from <= @Now
        ),
        campaigns_active =
        (
            SELECT COUNT(1)
            FROM dbo.loyalty_campaigns
            WHERE status = 'active'
        ),
        rewards_active =
        (
            SELECT COUNT(1)
            FROM dbo.loyalty_rewards
            WHERE status = 'active'
        ),
        level_benefits_active =
        (
            SELECT COUNT(1)
            FROM dbo.loyalty_level_benefits
            WHERE status = 'active'
        );
END
GO

