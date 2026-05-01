CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_bundle]
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.usp_loyalty_lookup_levels;
    EXEC dbo.usp_loyalty_lookup_rule_set_statuses;
    EXEC dbo.usp_loyalty_lookup_rule_statuses;
    EXEC dbo.usp_loyalty_lookup_rule_categories;
    EXEC dbo.usp_loyalty_lookup_rule_calculation_types;
    EXEC dbo.usp_loyalty_lookup_rule_stacking_modes;
    EXEC dbo.usp_loyalty_lookup_reward_statuses;
    EXEC dbo.usp_loyalty_lookup_reward_redemption_modes;
    EXEC dbo.usp_loyalty_lookup_reward_cumulative_modes;
    EXEC dbo.usp_loyalty_lookup_reward_usage_window_types;
    EXEC dbo.usp_loyalty_lookup_reward_availability_types;
    EXEC dbo.usp_loyalty_lookup_reward_season_types;
    EXEC dbo.usp_loyalty_lookup_redemption_statuses;
    EXEC dbo.usp_loyalty_lookup_redemption_request_channels;
    EXEC dbo.usp_loyalty_lookup_adjustment_types;
    EXEC dbo.usp_loyalty_lookup_adjustment_impact_types;
    EXEC dbo.usp_loyalty_lookup_adjustment_requested_by_types;
    EXEC dbo.usp_loyalty_lookup_adjustment_statuses;
    EXEC dbo.usp_loyalty_lookup_score_trend_codes;
    EXEC dbo.usp_loyalty_lookup_processing_stages;
    EXEC dbo.usp_loyalty_lookup_processing_statuses;
    EXEC dbo.usp_loyalty_lookup_campaign_audience_types;
    EXEC dbo.usp_loyalty_lookup_campaign_types;
    EXEC dbo.usp_loyalty_lookup_campaign_stacking_modes;
    EXEC dbo.usp_loyalty_lookup_campaign_statuses;
    EXEC dbo.usp_loyalty_lookup_condition_types;
    EXEC dbo.usp_loyalty_lookup_payment_methods;
    EXEC dbo.usp_loyalty_lookup_source_types;
END
GO

