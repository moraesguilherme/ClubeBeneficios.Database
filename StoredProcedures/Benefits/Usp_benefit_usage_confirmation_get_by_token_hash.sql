CREATE   PROCEDURE [dbo].[Usp_benefit_usage_confirmation_get_by_token_hash]
    @TokenHash VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        c.id,
        c.benefit_request_id,
        c.benefit_usage_id,
        c.benefit_id,
        c.partner_id,
        c.confirmation_type,
        c.confirmation_status,
        c.recipient_email,
        c.recipient_name,
        c.expires_at,
        c.confirmed_at,
        c.rejected_at,
        c.notification_id,
        c.created_at,
        c.updated_at,

        b.title AS benefit_title,
        p.trade_name AS partner_name,

        r.request_status,
        r.requester_type,

        CASE
            WHEN r.requester_type = 'client' THEN cl.full_name
            WHEN r.requester_type = 'partner_customer' THEN pc.full_name
            ELSE NULL
        END AS requester_name,

        CASE
            WHEN r.pet_source_type = 'client_pet' THEN cp.name
            WHEN r.pet_source_type = 'partner_customer_pet' THEN pcp.name
            ELSE NULL
        END AS pet_name
    FROM dbo.benefit_usage_confirmations c
    INNER JOIN dbo.benefit_requests r
        ON r.id = c.benefit_request_id
    INNER JOIN dbo.benefits b
        ON b.id = c.benefit_id
    INNER JOIN dbo.partners p
        ON p.id = c.partner_id
    LEFT JOIN dbo.clients cl
        ON cl.id = r.requester_client_id
    LEFT JOIN dbo.partner_customers pc
        ON pc.id = r.requester_partner_customer_id
    LEFT JOIN dbo.client_pets cp
        ON cp.id = r.requester_client_pet_id
    LEFT JOIN dbo.partner_customer_pets pcp
        ON pcp.id = r.requester_partner_customer_pet_id
    WHERE c.token_hash = @TokenHash;
END
GO

