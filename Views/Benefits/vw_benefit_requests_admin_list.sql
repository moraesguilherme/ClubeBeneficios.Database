CREATE   VIEW [dbo].[vw_benefit_requests_admin_list]
AS
SELECT
    r.id,
    r.benefit_id,
    b.title AS benefit_title,
    r.partner_id,
    p.trade_name AS partner_name,

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
    ON pcp.id = r.requester_partner_customer_pet_id;
GO


