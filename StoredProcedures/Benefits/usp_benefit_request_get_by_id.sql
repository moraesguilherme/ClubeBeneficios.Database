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
        v.benefit_direction,
        v.target_actor_type,
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
        v.requester_email,
        v.requester_phone,

        v.pet_source_type,
        v.requester_client_pet_id,
        v.requester_partner_customer_pet_id,

        v.pet_name,
        v.pet_species,
        v.pet_breed,
        v.pet_sex,
        v.pet_age_months,
        v.pet_weight_kg,
        v.pet_size,
        v.pet_is_neutered,
        v.pet_behavior_status,
        v.pet_status,

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

        latest_review.review_status AS latest_review_status,
        latest_review.review_point AS latest_review_point,
        latest_review.review_recommendation AS latest_review_recommendation,
        latest_review.reviewed_by_user_id AS latest_reviewed_by_user_id,
        latest_review.reviewed_at AS latest_reviewed_at,

        v.requested_at,
        v.scheduled_for,
        v.expires_at,
        v.created_at,
        v.updated_at,

        u.id AS usage_id,
        u.usage_status,
        u.used_at,
        u.monetary_value,
        u.discount_value,

        vc.id AS vaccination_card_id,
        vc.source_type AS vaccination_card_source_type,
        vc.client_document_id AS vaccination_card_client_document_id,
        vc.partner_customer_document_id AS vaccination_card_partner_customer_document_id,
        COALESCE(vc.file_url, pcd.file_url) AS vaccination_card_file_url,
        COALESCE(vc.file_name, pcd.file_name) AS vaccination_card_file_name,
        pcd.mime_type AS vaccination_card_mime_type,
        vc.submission_status AS vaccination_card_submission_status,
        vc.notes AS vaccination_card_notes,
        vc.reviewed_at AS vaccination_card_reviewed_at,
        vc.reviewed_by_user_id AS vaccination_card_reviewed_by_user_id,

        dw.id AS dewormer_id,
        dw.source_type AS dewormer_source_type,
        dw.client_pet_health_record_id AS dewormer_client_pet_health_record_id,
        dw.partner_customer_pet_health_record_id AS dewormer_partner_customer_pet_health_record_id,
        dw.application_type AS dewormer_application_type,
        dw.brand_name AS dewormer_brand_name,
        dw.applied_at AS dewormer_applied_at,
        dw.expires_at AS dewormer_expires_at,
        dw.submission_status AS dewormer_submission_status,
        dw.notes AS dewormer_notes,
        dw.reviewed_at AS dewormer_reviewed_at,
        dw.reviewed_by_user_id AS dewormer_reviewed_by_user_id,

        ft.id AS flea_tick_id,
        ft.source_type AS flea_tick_source_type,
        ft.client_pet_health_record_id AS flea_tick_client_pet_health_record_id,
        ft.partner_customer_pet_health_record_id AS flea_tick_partner_customer_pet_health_record_id,
        ft.application_type AS flea_tick_application_type,
        ft.brand_name AS flea_tick_brand_name,
        ft.applied_at AS flea_tick_applied_at,
        ft.expires_at AS flea_tick_expires_at,
        ft.submission_status AS flea_tick_submission_status,
        ft.notes AS flea_tick_notes,
        ft.reviewed_at AS flea_tick_reviewed_at,
        ft.reviewed_by_user_id AS flea_tick_reviewed_by_user_id
    FROM dbo.vw_benefit_request_detail v
    LEFT JOIN dbo.benefit_usages u
        ON u.benefit_request_id = v.id
       AND u.usage_status IN ('confirmed', 'used')

    OUTER APPLY
    (
        SELECT TOP 1
            rr.review_status,
            rr.review_point,
            rr.review_recommendation,
            rr.reviewed_by_user_id,
            rr.reviewed_at
        FROM dbo.benefit_request_reviews rr
        WHERE rr.benefit_request_id = v.id
        ORDER BY rr.reviewed_at DESC, rr.created_at DESC
    ) latest_review

    LEFT JOIN dbo.benefit_request_documents vc
        ON vc.benefit_request_id = v.id
       AND vc.document_type = 'vaccination_card'

    LEFT JOIN dbo.partner_customer_documents pcd
        ON pcd.id = vc.partner_customer_document_id

    LEFT JOIN dbo.benefit_request_preventives dw
        ON dw.benefit_request_id = v.id
       AND dw.preventive_type = 'dewormer'

    LEFT JOIN dbo.benefit_request_preventives ft
        ON ft.benefit_request_id = v.id
       AND ft.preventive_type = 'flea_tick'

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

