CREATE   VIEW [dbo].[vw_benefit_requests_customer_list]
AS
SELECT
    r.id,
    r.benefit_id,
    b.title AS benefit_title,
    b.benefit_type,
    b.direction,
    r.partner_id,
    p.trade_name AS partner_name,

    r.requester_type,
    r.requester_client_id,
    r.requester_partner_customer_id,

    r.pet_source_type,
    r.requester_client_pet_id,
    r.requester_partner_customer_pet_id,

    CASE
        WHEN r.pet_source_type = 'client_pet' THEN cp.name
        WHEN r.pet_source_type = 'partner_customer_pet' THEN pcp.name
        ELSE NULL
    END AS pet_name,

    r.request_status,
    r.approval_status,
    r.requested_at,
    r.scheduled_for,
    r.expires_at,
    r.updated_at
FROM dbo.benefit_requests r
INNER JOIN dbo.benefits b
    ON b.id = r.benefit_id
INNER JOIN dbo.partners p
    ON p.id = r.partner_id
LEFT JOIN dbo.client_pets cp
    ON cp.id = r.requester_client_pet_id
LEFT JOIN dbo.partner_customer_pets pcp
    ON pcp.id = r.requester_partner_customer_pet_id;
GO


