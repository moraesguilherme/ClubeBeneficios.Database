CREATE   PROCEDURE [dbo].[usp_clients_filter_options]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 'statuses' AS bucket, 'lead' AS value, 'Lead' AS label
    UNION ALL SELECT 'statuses', 'pending_profile', 'Perfil pendente'
    UNION ALL SELECT 'statuses', 'pending_documents', 'Documentos pendentes'
    UNION ALL SELECT 'statuses', 'pending_behavior_evaluation', 'Avaliação pendente'
    UNION ALL SELECT 'statuses', 'active', 'Ativo'
    UNION ALL SELECT 'statuses', 'inactive', 'Inativo'
    UNION ALL SELECT 'statuses', 'blocked', 'Bloqueado'
    UNION ALL SELECT 'statuses', 'archived', 'Arquivado'
    UNION ALL SELECT 'origin_types', 'manual', 'Manual'
    UNION ALL SELECT 'origin_types', 'site', 'Site'
    UNION ALL SELECT 'origin_types', 'landing_page', 'Landing page'
    UNION ALL SELECT 'origin_types', 'indication', 'Indicação'
    UNION ALL SELECT 'origin_types', 'partner_conversion', 'Conversão parceiro'
    UNION ALL SELECT 'origin_types', 'internal_import', 'Importação interna';
END
GO


