CREATE   VIEW [dbo].[vw_benefit_usage_overview]
AS
SELECT
    u.id,
    u.benefit_request_id,
    u.benefit_id,
    u.partner_id,
    p.trade_name AS partner_name,

    u.used_by_type,
    u.used_by_user_id,
    u.used_by_client_id,
    u.used_by_partner_customer_id,

    c.full_name AS client_name,
    pc.full_name AS partner_customer_name,

    CASE
        WHEN u.used_by_type = 'client' THEN c.full_name
        WHEN u.used_by_type = 'partner_customer' THEN pc.full_name
        ELSE NULL
    END AS used_by_name,

    u.pet_source_type,
    u.client_pet_id,
    u.partner_customer_pet_id,

    cp.name AS client_pet_name,
    pcp.name AS partner_customer_pet_name,

    CASE
        WHEN u.pet_source_type = 'client_pet' THEN cp.name
        WHEN u.pet_source_type = 'partner_customer_pet' THEN pcp.name
        ELSE NULL
    END AS pet_name,

    u.usage_status,
    u.used_at,
    u.confirmed_by_partner_user_id,
    u.confirmed_by_admin_user_id,
    u.recorded_by_user_id,

    u.snapshot_title,
    u.snapshot_partner_name,
    u.snapshot_rule_summary,
    u.monetary_value,
    u.discount_value,

    u.created_at,
    u.updated_at
FROM dbo.benefit_usages u
INNER JOIN dbo.partners p
    ON p.id = u.partner_id
LEFT JOIN dbo.clients c
    ON c.id = u.used_by_client_id
LEFT JOIN dbo.partner_customers pc
    ON pc.id = u.used_by_partner_customer_id
LEFT JOIN dbo.client_pets cp
    ON cp.id = u.client_pet_id
LEFT JOIN dbo.partner_customer_pets pcp
    ON pcp.id = u.partner_customer_pet_id;
GO

