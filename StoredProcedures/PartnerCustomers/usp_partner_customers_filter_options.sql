CREATE   PROCEDURE [dbo].[usp_partner_customers_filter_options]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 'statuses' AS bucket, 'active' AS value, 'Ativo' AS label
    UNION ALL SELECT 'statuses', 'inactive', 'Inativo'
    UNION ALL SELECT 'statuses', 'blocked', 'Bloqueado'
    UNION ALL SELECT 'statuses', 'archived', 'Arquivado'
    UNION ALL SELECT 'registration_stages', 'pre_registered', 'Pré-cadastro'
    UNION ALL SELECT 'registration_stages', 'dashboard_enabled', 'Dashboard liberada'
    UNION ALL SELECT 'registration_stages', 'profile_completed', 'Perfil completo'
    UNION ALL SELECT 'registration_stages', 'pet_completed', 'Pet completo'
    UNION ALL SELECT 'registration_stages', 'documents_pending', 'Documentos pendentes'
    UNION ALL SELECT 'registration_stages', 'under_review', 'Em análise'
    UNION ALL SELECT 'registration_stages', 'eligible', 'Elegível'
    UNION ALL SELECT 'registration_stages', 'ineligible', 'Inelegível'
    UNION ALL SELECT 'origin_types', 'partner_qr_code', 'QR code do parceiro'
    UNION ALL SELECT 'origin_types', 'partner_access_code', 'Código do parceiro'
    UNION ALL SELECT 'origin_types', 'manual', 'Manual'
    UNION ALL SELECT 'origin_types', 'imported', 'Importado'
    UNION ALL SELECT 'origin_channels', 'qr_code', 'QR code'
    UNION ALL SELECT 'origin_channels', 'landing_page', 'Landing page'
    UNION ALL SELECT 'origin_channels', 'manual_code', 'Código manual'
    UNION ALL SELECT 'origin_channels', 'internal', 'Interno';
END
GO

