CREATE VIEW dbo.vw_partner_pending_details
AS
SELECT
    p.id,
    p.trade_name,
    p.legal_name,
    p.document,
    p.email,
    p.phone,
    p.status,
    p.logo_url,
    p.segment,
    p.category,
    p.service_region,
    p.description,
    p.created_at,
    c.name AS responsible_name,
    c.role_name AS responsible_role,
    c.email AS responsible_email,
    c.phone AS responsible_phone,
    (
        SELECT TOP (1) n.content
        FROM dbo.partner_notes n
        WHERE n.partner_id = p.id
        ORDER BY n.created_at DESC
    ) AS latest_note
FROM dbo.partners p
LEFT JOIN dbo.partner_contacts c
    ON c.partner_id = p.id
   AND c.is_primary = 1
WHERE p.status IN ('pending', 'under_review');
GO
