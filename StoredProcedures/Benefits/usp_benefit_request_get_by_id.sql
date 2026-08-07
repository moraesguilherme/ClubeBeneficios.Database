CREATE   PROCEDURE [dbo].[usp_benefit_request_get_by_id]
    @BenefitRequestId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        v.id,
        v.benefit_id,
        v.benefit_title,
        v.benefit_status,
        v.benefit_type,
        v.direction AS benefit_direction,
        v.eligibility_type,

        v.partner_id,
        v.partner_name,
        v.partner_segment,
        v.partner_category,

        v.requester_type,
        v.requester_user_id,
        v.requester_client_id,
        v.requester_partner_customer_id,
        v.requested_by_user_id,

        v.client_name,
        v.client_document,
        v.client_email,
        v.client_phone,
        v.client_status,

        v.partner_customer_name,
        v.partner_customer_document,
        v.partner_customer_email,
        v.partner_customer_phone,
        v.partner_customer_status,
        v.partner_customer_registration_stage,

        v.requester_name,

        CASE
            WHEN v.requester_type = 'client' THEN v.client_email
            WHEN v.requester_type = 'partner_customer' THEN v.partner_customer_email
            ELSE NULL
        END AS requester_email,

        CASE
            WHEN v.requester_type = 'client' THEN v.client_phone
            WHEN v.requester_type = 'partner_customer' THEN v.partner_customer_phone
            ELSE NULL
        END AS requester_phone,

        v.pet_source_type,
        v.requester_client_pet_id,
        v.requester_partner_customer_pet_id,

        v.pet_name,

        CASE
            WHEN v.pet_source_type = 'client_pet' THEN v.client_pet_species
            WHEN v.pet_source_type = 'partner_customer_pet' THEN v.partner_customer_pet_species
            ELSE NULL
        END AS pet_species,

        CASE
            WHEN v.pet_source_type = 'client_pet' THEN v.client_pet_breed
            WHEN v.pet_source_type = 'partner_customer_pet' THEN v.partner_customer_pet_breed
            ELSE NULL
        END AS pet_breed,

        CASE
            WHEN v.pet_source_type = 'client_pet' THEN v.client_pet_sex
            WHEN v.pet_source_type = 'partner_customer_pet' THEN v.partner_customer_pet_sex
            ELSE NULL
        END AS pet_sex,

        CASE
            WHEN v.pet_source_type = 'client_pet' THEN v.client_pet_behavior_status
            WHEN v.pet_source_type = 'partner_customer_pet' THEN v.partner_customer_pet_behavior_status
            ELSE NULL
        END AS pet_behavior_status,

        CASE
            WHEN v.pet_source_type = 'client_pet' THEN v.client_pet_status
            WHEN v.pet_source_type = 'partner_customer_pet' THEN v.partner_customer_pet_status
            ELSE NULL
        END AS pet_status,

        v.access_code_id,
        v.access_code,

        v.request_status,
        v.review_required,
        v.approval_status,
        v.approval_requested_at,
        v.approval_decided_at,
        v.approval_decided_by_user_id,
        v.approval_reason,

        v.reviewed_at,
        v.reviewed_by_user_id,
        v.review_notes,

        v.requested_at,
        v.scheduled_for,
        v.expires_at,
        v.created_at,
        v.updated_at,

        u.id AS usage_id,
        u.usage_status,
        u.used_at,
        u.monetary_value,
        u.discount_value
    FROM dbo.vw_benefit_request_detail v
    LEFT JOIN dbo.benefit_usages u
        ON u.benefit_request_id = v.id
       AND u.usage_status IN ('confirmed', 'used')
    WHERE v.id = @BenefitRequestId
    ORDER BY u.used_at DESC, u.created_at DESC;

    SELECT
        rr.id,
        rr.benefit_request_id,
        rr.review_status,
        rr.review_point,
        rr.review_recommendation,
        rr.reviewed_by_user_id,
        u.name AS reviewed_by_name,
        rr.reviewed_at,
        rr.created_at
    FROM dbo.benefit_request_reviews rr
    LEFT JOIN dbo.users u
        ON u.id = rr.reviewed_by_user_id
    WHERE rr.benefit_request_id = @BenefitRequestId
    ORDER BY rr.reviewed_at ASC, rr.created_at ASC;

    SELECT
        e.id,
        e.benefit_request_id,
        e.event_type,
        e.event_status,
        e.event_point,
        e.event_description,
        e.actor_user_id,
        u.name AS actor_name,
        e.occurred_at,
        e.created_at
    FROM dbo.benefit_request_timeline_events e
    LEFT JOIN dbo.users u
        ON u.id = e.actor_user_id
    WHERE e.benefit_request_id = @BenefitRequestId
    ORDER BY e.occurred_at ASC, e.created_at ASC;
END
GO

