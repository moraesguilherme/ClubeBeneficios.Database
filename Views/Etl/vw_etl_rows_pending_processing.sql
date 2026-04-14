CREATE VIEW [dbo].[vw_etl_rows_pending_processing]
AS
SELECT
    r.id,
    r.batch_id,
    r.row_number,
    r.external_row_key,
    r.occurred_at,
    r.competence_date,
    r.customer_name_raw,
    r.customer_document_raw,
    r.customer_email_raw,
    r.customer_phone_raw,
    r.pet_name_raw,
    r.partner_name_raw,
    r.service_type_raw,
    r.plan_name_raw,
    r.package_name_raw,
    r.lodging_type_raw,
    r.payment_method_raw,
    r.payment_method_normalized,
    r.gross_amount,
    r.discount_amount,
    r.net_amount,
    r.quantity,
    r.status,
    r.parsed_at,
    r.processed_at,
    m.client_id,
    m.user_id,
    m.client_pet_id,
    m.partner_id,
    m.match_status,
    m.match_confidence,
    m.matched_by_rule,
    m.review_required,
    m.reviewed_at,
    m.reviewed_by_user_id,
    m.review_notes
FROM dbo.etl_import_rows r
LEFT JOIN dbo.etl_import_row_matches m
    ON m.import_row_id = r.id
WHERE
    r.status IN ('parsed', 'matched')
    AND ISNULL(m.review_required, 0) = 0;

GO


