CREATE VIEW [dbo].[vw_etl_hotel_rows_pending_parse]
AS
SELECT
    r.id,
    r.batch_id,
    r.row_number,
    r.external_row_key,
    r.raw_payload_json,
    r.source_sheet_name,
    r.source_sheet_group,
    r.reference_year,
    r.reference_month,
    r.customer_name_raw,
    r.customer_document_raw,
    r.customer_document_normalized,
    r.customer_phone_raw,
    r.customer_phone_normalized,
    r.pet_name_raw,
    r.partner_name_raw,
    r.service_type_raw,
    r.service_type_normalized,
    r.plan_name_raw,
    r.package_name_raw,
    r.payment_status_raw,
    r.payment_status_normalized,
    r.payment_method_raw,
    r.payment_method_normalized,
    r.gross_amount,
    r.discount_amount,
    r.net_amount,
    r.taxi_amount,
    r.quantity,
    r.occurred_at,
    r.start_date,
    r.end_date,
    r.competence_date,
    r.description_raw,
    r.observation_raw,
    r.status
FROM dbo.etl_import_rows r
WHERE (r.source_file_type = 'hotel_agenda' OR r.source_sheet_name = 'AGENDA 2026')
  AND r.status IN ('pending', 'parsed');
GO


