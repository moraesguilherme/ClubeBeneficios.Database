CREATE VIEW [dbo].[vw_etl_rows_ready_for_loyalty_event]
AS
SELECT
    r.id AS import_row_id,
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
    m.client_id,
    m.user_id,
    m.client_pet_id,
    m.partner_id,
    m.match_status,
    m.match_confidence,
    m.matched_by_rule,
    m.review_required
FROM dbo.etl_import_rows r
INNER JOIN dbo.etl_import_row_matches m
    ON m.import_row_id = r.id
WHERE
    r.status = 'matched'
    AND ISNULL(m.review_required, 0) = 0
    AND m.client_id IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.customer_loyalty_events e
        WHERE
            e.source_type = 'etl_payment_row'
            AND e.source_id = CONVERT(varchar(100), r.id)
    );

GO


