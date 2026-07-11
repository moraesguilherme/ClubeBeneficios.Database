CREATE   PROCEDURE [dbo].[usp_benefits_get_by_id]
    @BenefitId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.benefits
        WHERE id = @BenefitId
    )
    BEGIN
        RAISERROR('Benefício não encontrado.', 16, 1);
        RETURN;
    END

    /* Resultado 1: dados principais */
    SELECT
        b.id,
        b.partner_id,
        p.trade_name AS partner_name,
        p.legal_name AS partner_legal_name,
        p.segment AS partner_segment,
        p.category AS partner_category,
        p.logo_url AS partner_logo_url,
        p.level AS partner_level,
        p.status AS partner_status,

        b.created_by_user_id,
        created_user.name AS created_by_user_name,

        b.updated_by_user_id,
        updated_user.name AS updated_by_user_name,

        b.approved_by_user_id,
        approved_user.name AS approved_by_user_name,

        b.rejected_by_user_id,
        rejected_user.name AS rejected_by_user_name,

        b.title,
        b.benefit_type,
        b.direction,
        b.target_actor_type,
        b.status,

        CASE
            WHEN b.direction = 'matilha_to_partner' THEN 'matilha'
            WHEN b.direction = 'partner_to_matilha' THEN 'partner'
            ELSE NULL
        END AS operational_owner,

        CASE
            WHEN b.direction = 'matilha_to_partner' THEN 'Matilha'
            WHEN b.direction = 'partner_to_matilha' THEN p.trade_name
            ELSE NULL
        END AS provider_label,

        b.short_description,
        b.full_description,
        b.internal_notes,

        b.eligibility_type,

        b.recurrence_type,
        b.recurrence_value,
        b.recurrence_period,

        b.validity_type,
        b.starts_at,
        b.ends_at,

        b.requires_manual_release,
        b.auto_activate_when_approved,
        b.highlight_in_showcase,
        b.allow_first_use_only,
        b.requires_active_access_code,
        b.requires_partner_availability,
        b.requires_matilha_acceptance_rules,
        b.stacking_rule,

        b.approval_notes,
        b.rejection_reason,
        b.approved_at,
        b.rejected_at,
        b.inactivated_at,

        ISNULL(ms.requests_count, 0) AS requests_count,
        ISNULL(ms.approved_requests_count, 0) AS approved_requests_count,
        ISNULL(ms.usages_count, 0) AS usages_count,
        ISNULL(ms.conversion_rate, 0) AS conversion_rate,
        ms.refreshed_at AS metrics_refreshed_at,

        b.created_at,
        b.updated_at
    FROM dbo.benefits b
    INNER JOIN dbo.partners p
        ON p.id = b.partner_id
    LEFT JOIN dbo.users created_user
        ON created_user.id = b.created_by_user_id
    LEFT JOIN dbo.users updated_user
        ON updated_user.id = b.updated_by_user_id
    LEFT JOIN dbo.users approved_user
        ON approved_user.id = b.approved_by_user_id
    LEFT JOIN dbo.users rejected_user
        ON rejected_user.id = b.rejected_by_user_id
    LEFT JOIN dbo.benefit_metrics_snapshot ms
        ON ms.benefit_id = b.id
    WHERE b.id = @BenefitId;

    /* Resultado 2: níveis vinculados */
    SELECT
        id,
        benefit_id,
        level_type,
        level_code,
        created_at
    FROM dbo.benefit_level_scopes
    WHERE benefit_id = @BenefitId
    ORDER BY
        CASE level_code
            WHEN 'bronze' THEN 1
            WHEN 'silver' THEN 2
            WHEN 'gold' THEN 3
            WHEN 'diamond' THEN 4
            WHEN 'platinum' THEN 5
            ELSE 99
        END;

    /* Resultado 3: regras comportamentais */
    SELECT
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
    FROM dbo.benefit_behavior_rules
    WHERE benefit_id = @BenefitId;

    /* Resultado 4: regras de código */
    SELECT
        cr.id,
        cr.benefit_id,
        cr.requires_access_code,
        cr.allow_any_active_partner_code,
        cr.specific_access_code_id,
        pac.code AS specific_access_code,
        pac.status AS specific_access_code_status,
        pac.expires_at AS specific_access_code_expires_at,
        cr.code_validation_mode,
        cr.created_at,
        cr.updated_at
    FROM dbo.benefit_code_rules cr
    LEFT JOIN dbo.partner_access_codes pac
        ON pac.id = cr.specific_access_code_id
    WHERE cr.benefit_id = @BenefitId;

    /* Resultado 5: reviews da publicação do benefício */
    SELECT
        r.id,
        r.benefit_id,
        r.review_status,
        r.review_point,
        r.review_recommendation,
        r.reviewed_by_user_id,
        u.name AS reviewed_by_user_name,
        r.reviewed_at,
        r.created_at
    FROM dbo.benefit_reviews r
    INNER JOIN dbo.users u
        ON u.id = r.reviewed_by_user_id
    WHERE r.benefit_id = @BenefitId
    ORDER BY r.reviewed_at DESC, r.created_at DESC;

    /* Resultado 6: histórico de status */
    SELECT
        h.id,
        h.benefit_id,
        h.from_status,
        h.to_status,
        h.reason,
        h.changed_by_user_id,
        u.name AS changed_by_user_name,
        h.changed_at
    FROM dbo.benefit_status_history h
    LEFT JOIN dbo.users u
        ON u.id = h.changed_by_user_id
    WHERE h.benefit_id = @BenefitId
    ORDER BY h.changed_at DESC, h.id DESC;
END
GO

