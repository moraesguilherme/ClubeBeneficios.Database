CREATE   PROCEDURE [dbo].[usp_benefit_requests_filter_options]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 'requester_types' AS bucket, 'client' AS value, 'Cliente Matilha' AS label
    UNION ALL
    SELECT 'requester_types', 'partner_customer', 'Cliente do parceiro'
    UNION ALL
    SELECT 'request_statuses', 'requested', 'Solicitado'
    UNION ALL
    SELECT 'request_statuses', 'pending_review', 'Pendente de análise'
    UNION ALL
    SELECT 'request_statuses', 'under_review', 'Em análise'
    UNION ALL
    SELECT 'request_statuses', 'approved', 'Aprovado'
    UNION ALL
    SELECT 'request_statuses', 'declined', 'Recusado'
    UNION ALL
    SELECT 'request_statuses', 'cancelled', 'Cancelado'
    UNION ALL
    SELECT 'request_statuses', 'expired', 'Expirado'
    UNION ALL
    SELECT 'request_statuses', 'scheduled', 'Agendado'
    UNION ALL
    SELECT 'request_statuses', 'no_show', 'Não compareceu'
    UNION ALL
    SELECT 'request_statuses', 'converted_to_usage', 'Convertido em utilização'
    UNION ALL
    SELECT 'approval_statuses', 'pending_review', 'Pendente de análise'
    UNION ALL
    SELECT 'approval_statuses', 'under_review', 'Em análise'
    UNION ALL
    SELECT 'approval_statuses', 'approved', 'Aprovado'
    UNION ALL
    SELECT 'approval_statuses', 'rejected', 'Rejeitado'
    UNION ALL
    SELECT 'approval_statuses', 'cancelled', 'Cancelado'
    UNION ALL
    SELECT 'approval_statuses', 'expired', 'Expirado'
    UNION ALL
    SELECT 'pet_source_types', 'client_pet', 'Pet do cliente Matilha'
    UNION ALL
    SELECT 'pet_source_types', 'partner_customer_pet', 'Pet do cliente parceiro';
END
GO


