CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_processing_stages]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('eligibility_check', 'Validação de elegibilidade', 1),
            ('event_creation',    'Criação de evento',          2),
            ('balance_rebuild',   'Rebuild de saldo',           3),
            ('metrics_rebuild',   'Rebuild de métricas',        4),
            ('finalization',      'Finalização',                5)
    ) AS x(stage_code, stage_name, display_order)
    ORDER BY x.display_order;
END
GO

