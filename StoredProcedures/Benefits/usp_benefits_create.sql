CREATE   PROCEDURE [dbo].[usp_benefits_create]
    @PartnerId UNIQUEIDENTIFIER,
    @Title VARCHAR(180),
    @BenefitType VARCHAR(40),
    @Direction VARCHAR(30),
    @TargetActorType VARCHAR(30),
    @ShortDescription VARCHAR(500) = NULL,
    @FullDescription VARCHAR(3000) = NULL,
    @InternalNotes VARCHAR(MAX) = NULL,
    @EligibilityType VARCHAR(30) = 'open',
    @RecurrenceType VARCHAR(40) = 'once_per_customer',
    @RecurrenceValue INT = NULL,
    @RecurrencePeriod VARCHAR(20) = NULL,
    @ValidityType VARCHAR(30) = 'continuous',
    @StartsAt DATETIME2(7) = NULL,
    @EndsAt DATETIME2(7) = NULL,
    @RequiresManualRelease BIT = 0,
    @AutoActivateWhenApproved BIT = 1,
    @HighlightInShowcase BIT = 0,
    @AllowFirstUseOnly BIT = 0,
    @RequiresActiveAccessCode BIT = 0,
    @RequiresPartnerAvailability BIT = 1,
    @RequiresMatilhaAcceptanceRules BIT = 0,
    @StackingRule VARCHAR(30) = 'non_cumulative',
    @LevelCodesCsv VARCHAR(500) = NULL,
    @LevelType VARCHAR(30) = NULL,
    @MinFrequencyEnabled BIT = 0,
    @MinFrequencyValue INT = NULL,
    @FrequencyWindowMonths INT = NULL,
    @MinTicketEnabled BIT = 0,
    @MinTicketValue DECIMAL(18,2) = NULL,
    @TicketWindowMonths INT = NULL,
    @BehaviorFirstUseOnly BIT = 0,
    @BehaviorRequiresMatilhaApproval BIT = 0,
    @CustomRuleText VARCHAR(1500) = NULL,
    @RequiresAccessCode BIT = 0,
    @AllowAnyActivePartnerCode BIT = 1,
    @SpecificAccessCodeId UNIQUEIDENTIFIER = NULL,
    @CodeValidationMode VARCHAR(30) = 'partner_code',
    @CreatedByUserId UNIQUEIDENTIFIER = NULL,
    @InitialStatus VARCHAR(30) = 'pending_review'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @BenefitId UNIQUEIDENTIFIER = NEWID();

    BEGIN TRANSACTION;

    INSERT INTO dbo.benefits
    (
        id, partner_id, created_by_user_id, updated_by_user_id,
        title, benefit_type, direction, target_actor_type, status,
        short_description, full_description, internal_notes,
        eligibility_type, recurrence_type, recurrence_value, recurrence_period,
        validity_type, starts_at, ends_at,
        requires_manual_release, auto_activate_when_approved, highlight_in_showcase,
        allow_first_use_only, requires_active_access_code, requires_partner_availability, requires_matilha_acceptance_rules,
        stacking_rule, created_at, updated_at
    )
    VALUES
    (
        @BenefitId, @PartnerId, @CreatedByUserId, @CreatedByUserId,
        @Title, @BenefitType, @Direction, @TargetActorType, @InitialStatus,
        @ShortDescription, @FullDescription, @InternalNotes,
        @EligibilityType, @RecurrenceType, @RecurrenceValue, @RecurrencePeriod,
        @ValidityType, @StartsAt, @EndsAt,
        @RequiresManualRelease, @AutoActivateWhenApproved, @HighlightInShowcase,
        @AllowFirstUseOnly, @RequiresActiveAccessCode, @RequiresPartnerAvailability, @RequiresMatilhaAcceptanceRules,
        @StackingRule, SYSUTCDATETIME(), SYSUTCDATETIME()
    );

    IF @LevelCodesCsv IS NOT NULL AND LTRIM(RTRIM(@LevelCodesCsv)) <> ''
    BEGIN
        INSERT INTO dbo.benefit_level_scopes
        (
            id, benefit_id, level_type, level_code, created_at
        )
        SELECT
            NEWID(), @BenefitId, ISNULL(@LevelType, 'client_level'), LTRIM(RTRIM(value)), SYSUTCDATETIME()
        FROM STRING_SPLIT(@LevelCodesCsv, ',')
        WHERE LTRIM(RTRIM(value)) <> '';
    END

    IF @EligibilityType IN ('behavior', 'hybrid')
    BEGIN
        INSERT INTO dbo.benefit_behavior_rules
        (
            id, benefit_id, min_frequency_enabled, min_frequency_value, frequency_window_months,
            min_ticket_enabled, min_ticket_value, ticket_window_months,
            first_use_only, requires_matilha_approval, custom_rule_text,
            created_at, updated_at
        )
        VALUES
        (
            NEWID(), @BenefitId, @MinFrequencyEnabled, @MinFrequencyValue, @FrequencyWindowMonths,
            @MinTicketEnabled, @MinTicketValue, @TicketWindowMonths,
            @BehaviorFirstUseOnly, @BehaviorRequiresMatilhaApproval, @CustomRuleText,
            SYSUTCDATETIME(), SYSUTCDATETIME()
        );
    END

    IF @EligibilityType IN ('code', 'hybrid') OR @RequiresAccessCode = 1 OR @RequiresActiveAccessCode = 1
    BEGIN
        INSERT INTO dbo.benefit_code_rules
        (
            id, benefit_id, requires_access_code, allow_any_active_partner_code,
            specific_access_code_id, code_validation_mode, created_at, updated_at
        )
        VALUES
        (
            NEWID(), @BenefitId, @RequiresAccessCode, @AllowAnyActivePartnerCode,
            @SpecificAccessCodeId, @CodeValidationMode, SYSUTCDATETIME(), SYSUTCDATETIME()
        );
    END

    INSERT INTO dbo.benefit_status_history
    (
        benefit_id, from_status, to_status, reason, changed_by_user_id, changed_at
    )
    VALUES
    (
        @BenefitId, NULL, @InitialStatus, 'Cadastro inicial do benefício.', @CreatedByUserId, SYSUTCDATETIME()
    );

    INSERT INTO dbo.benefit_metrics_snapshot
    (
        benefit_id, requests_count, approved_requests_count, usages_count, conversion_rate, refreshed_at
    )
    VALUES
    (
        @BenefitId, 0, 0, 0, 0, SYSUTCDATETIME()
    );

    COMMIT TRANSACTION;

    SELECT @BenefitId AS benefit_id;
END

GO


