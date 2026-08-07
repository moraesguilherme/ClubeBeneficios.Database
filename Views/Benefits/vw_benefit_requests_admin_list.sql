CREATE VIEW [dbo].[vw_benefit_requests_admin_list]
AS
SELECT
    r.id,
    r.benefit_id,
    b.title AS benefit_title,
    b.status AS benefit_status,
    b.benefit_type,
    b.direction AS benefit_direction,
    b.target_actor_type,
    b.eligibility_type,

    CASE
        WHEN b.direction = 'partner_to_matilha' THEN 'partner'
        WHEN b.direction = 'matilha_to_partner' THEN 'matilha'
        ELSE NULL
    END AS operational_owner,

    CASE
        WHEN b.direction = 'partner_to_matilha' THEN p.trade_name
        WHEN b.direction = 'matilha_to_partner' THEN 'Matilha Feliz'
        ELSE NULL
    END AS provider_label,

    r.partner_id,
    p.trade_name AS partner_name,
    p.segment AS partner_segment,
    p.category AS partner_category,

    r.requester_type,
    r.requester_user_id,
    r.requester_client_id,
    r.requester_partner_customer_id,
    r.requested_by_user_id,

    c.full_name AS client_name,
    c.email AS client_email,
    c.phone AS client_phone,

    pc.full_name AS partner_customer_name,
    pc.email AS partner_customer_email,
    pc.phone AS partner_customer_phone,

    CASE
        WHEN r.requester_type = 'client' THEN
            COALESCE(NULLIF(c.full_name, ''), 'Cliente Matilha sem nome')

        WHEN r.requester_type = 'partner_customer' THEN
            CASE
                WHEN pc.full_name IS NULL
                  OR LTRIM(RTRIM(pc.full_name)) = ''
                  OR pc.full_name LIKE 'Cliente sem identificação - %'
                    THEN 'Cliente do parceiro sem nome'
                ELSE pc.full_name
            END

        ELSE 'Solicitante não informado'
    END AS requester_name,

    CASE
        WHEN r.requester_type = 'client' THEN c.email
        WHEN r.requester_type = 'partner_customer' THEN pc.email
        ELSE NULL
    END AS requester_email,

    CASE
        WHEN r.requester_type = 'client' THEN c.phone
        WHEN r.requester_type = 'partner_customer' THEN pc.phone
        ELSE NULL
    END AS requester_phone,

    r.pet_source_type,
    r.requester_client_pet_id,
    r.requester_partner_customer_pet_id,

    cp.name AS client_pet_name,
    pcp.name AS partner_customer_pet_name,

    CASE
        WHEN r.pet_source_type = 'client_pet' THEN cp.name
        WHEN r.pet_source_type = 'partner_customer_pet' THEN pcp.name
        ELSE NULL
    END AS pet_name,

    CASE
        WHEN r.pet_source_type = 'client_pet' THEN cp.breed
        WHEN r.pet_source_type = 'partner_customer_pet' THEN pcp.breed
        ELSE NULL
    END AS pet_breed,

    CASE
        WHEN r.pet_source_type = 'client_pet' THEN cp.sex
        WHEN r.pet_source_type = 'partner_customer_pet' THEN pcp.sex
        ELSE NULL
    END AS pet_sex,

    CASE
        WHEN r.pet_source_type = 'client_pet' THEN cp.behavior_status
        WHEN r.pet_source_type = 'partner_customer_pet' THEN pcp.behavior_status
        ELSE NULL
    END AS pet_behavior_status,

    r.access_code_id,
    pac.code AS access_code,

    r.request_status,
    r.review_required,
    r.approval_status,
    r.approval_requested_at,
    r.approval_decided_at,
    r.approval_decided_by_user_id,
    r.approval_reason,

    r.reviewed_at,
    r.reviewed_by_user_id,
    r.review_notes,

    CAST(NULL AS varchar(30)) AS latest_review_status,
    CAST(NULL AS varchar(200)) AS latest_review_point,
    CAST(NULL AS varchar(1500)) AS latest_review_recommendation,
    CAST(NULL AS uniqueidentifier) AS latest_reviewed_by_user_id,
    CAST(NULL AS datetime2(7)) AS latest_reviewed_at,

    CAST(NULL AS varchar(30)) AS vaccination_card_submission_status,
    CAST(NULL AS varchar(30)) AS dewormer_submission_status,
    CAST(NULL AS varchar(30)) AS flea_tick_submission_status,
    CAST(NULL AS varchar(30)) AS request_health_review_status,

    r.requested_at,
    r.scheduled_for,
    r.expires_at,
    r.created_at,
    r.updated_at
FROM dbo.benefit_requests r
INNER JOIN dbo.benefits b
    ON b.id = r.benefit_id
INNER JOIN dbo.partners p
    ON p.id = r.partner_id
LEFT JOIN dbo.clients c
    ON c.id = r.requester_client_id
LEFT JOIN dbo.partner_customers pc
    ON pc.id = r.requester_partner_customer_id
LEFT JOIN dbo.client_pets cp
    ON cp.id = r.requester_client_pet_id
LEFT JOIN dbo.partner_customer_pets pcp
    ON pcp.id = r.requester_partner_customer_pet_id
LEFT JOIN dbo.partner_access_codes pac
    ON pac.id = r.access_code_id;
GO

