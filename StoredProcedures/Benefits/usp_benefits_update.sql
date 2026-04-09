CREATE   PROCEDURE [dbo].[usp_benefits_update]
    @BenefitId UNIQUEIDENTIFIER,
    @PartnerId UNIQUEIDENTIFIER = NULL,
    @Title VARCHAR(180),
    @BenefitType VARCHAR(40),
    @Direction VARCHAR(30) = NULL,
    @TargetActorType VARCHAR(30),
    @ShortDescription VARCHAR(500) = NULL,
    @FullDescription VARCHAR(3000) = NULL,
    @InternalNotes VARCHAR(MAX) = NULL,
    @Status VARCHAR(30) = NULL,
    @EligibilityType VARCHAR(30),
    @RecurrenceType VARCHAR(40),
    @RecurrenceValue INT = NULL,
    @RecurrencePeriod VARCHAR(20) = NULL,
    @ValidityType VARCHAR(30),
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
    @UpdatedByUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    UPDATE dbo.benefits
    SET
        partner_id = ISNULL(@PartnerId, partner_id),
        title = @Title,
        benefit_type = @BenefitType,
        direction = ISNULL(@Direction, direction),
        target_actor_type = @TargetActorType,
        status = ISNULL(@Status, status),
        short_description = @ShortDescription,
        full_description = @FullDescription,
        internal_notes = @InternalNotes,
        eligibility_type = @EligibilityType,
        recurrence_type = @RecurrenceType,
        recurrence_value = @RecurrenceValue,
        recurrence_period = @RecurrencePeriod,
        validity_type = @ValidityType,
        starts_at = @StartsAt,
        ends_at = @EndsAt,
        requires_manual_release = @RequiresManualRelease,
        auto_activate_when_approved = @AutoActivateWhenApproved,
        highlight_in_showcase = @HighlightInShowcase,
        allow_first_use_only = @AllowFirstUseOnly,
        requires_active_access_code = @RequiresActiveAccessCode,
        requires_partner_availability = @RequiresPartnerAvailability,
        requires_matilha_acceptance_rules = @RequiresMatilhaAcceptanceRules,
        stacking_rule = @StackingRule,
        updated_by_user_id = @UpdatedByUserId,
        updated_at = SYSUTCDATETIME()
    WHERE id = @BenefitId;

    DELETE FROM dbo.benefit_level_scopes
    WHERE benefit_id = @BenefitId;

    IF @LevelCodesCsv IS NOT NULL AND LTRIM(RTRIM(@LevelCodesCsv)) <> ''
    BEGIN
        INSERT INTO dbo.benefit_level_scopes
        (
            id,
            benefit_id,
            level_type,
            level_code,
            created_at
        )
        SELECT
            NEWID(),
            @BenefitId,
            ISNULL(@LevelType, 'client_level'),
            LTRIM(RTRIM(value)),
            SYSUTCDATETIME()
        FROM STRING_SPLIT(@LevelCodesCsv, ',')
        WHERE LTRIM(RTRIM(value)) <> '';
    END

    DELETE FROM dbo.benefit_behavior_rules
    WHERE benefit_id = @BenefitId;

    IF @EligibilityType IN ('behavior', 'hybrid')
    BEGIN
        INSERT INTO dbo.benefit_behavior_rules
        (
            id,
            benefit_id,
            min_frequency_enabled,
            min_frequency_value,
            frequency_window_months,
            min_ticket_enabled,
            min_ticket_value,
            ticket_window_months,
            first_use_only,
            requires_matilha_approval,
            custom_rule_text,
            created_at,
            updated_at
        )
        VALUES
        (
            NEWID(),
            @BenefitId,
            @MinFrequencyEnabled,
            @MinFrequencyValue,
            @FrequencyWindowMonths,
            @MinTicketEnabled,
            @MinTicketValue,
            @TicketWindowMonths,
            @BehaviorFirstUseOnly,
            @BehaviorRequiresMatilhaApproval,
            @CustomRuleText,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END

    DELETE FROM dbo.benefit_code_rules
    WHERE benefit_id = @BenefitId;

    IF @EligibilityType IN ('code', 'hybrid')
       OR @RequiresAccessCode = 1
       OR @RequiresActiveAccessCode = 1
    BEGIN
        INSERT INTO dbo.benefit_code_rules
        (
            id,
            benefit_id,
            requires_access_code,
            allow_any_active_partner_code,
            specific_access_code_id,
            code_validation_mode,
            created_at,
            updated_at
        )
        VALUES
        (
            NEWID(),
            @BenefitId,
            @RequiresAccessCode,
            @AllowAnyActivePartnerCode,
            @SpecificAccessCodeId,
            @CodeValidationMode,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END

    COMMIT TRANSACTION;
END
GO


