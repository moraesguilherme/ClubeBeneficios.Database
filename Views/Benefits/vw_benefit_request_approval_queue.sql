CREATE   VIEW [dbo].[vw_benefit_request_approval_queue]
AS
SELECT
    r.id,
    r.benefit_id,
    b.title AS benefit_title,
    b.status AS benefit_status,
    b.benefit_type,
    b.direction,
    b.eligibility_type,

    r.partner_id,
    p.trade_name AS partner_name,
    p.segment AS partner_segment,
    p.category AS partner_category,
    p.status AS partner_status,

    r.requester_type,
    r.requester_client_id,
    r.requester_partner_customer_id,

    c.full_name AS client_name,
    c.email AS client_email,
    c.phone AS client_phone,
    c.status AS client_status,

    pc.full_name AS partner_customer_name,
    pc.email AS partner_customer_email,
    pc.phone AS partner_customer_phone,
    pc.status AS partner_customer_status,
    pc.registration_stage AS partner_customer_registration_stage,

    CASE
        WHEN r.requester_type = 'client' THEN c.full_name
        WHEN r.requester_type = 'partner_customer' THEN pc.full_name
        ELSE NULL
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

    r.requested_at,
    r.scheduled_for,
    r.expires_at,
    r.created_at,
    r.updated_at,

    CASE
        WHEN r.expires_at IS NOT NULL AND r.expires_at < SYSUTCDATETIME() THEN 1
        ELSE 0
    END AS is_expired,

    CASE
        WHEN r.approval_status IN ('pending_review', 'under_review') THEN 1
        ELSE 0
    END AS is_pending_queue
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
    ON pac.id = r.access_code_id
WHERE
    r.review_required = 1
    OR r.approval_status IS NOT NULL;
GO


