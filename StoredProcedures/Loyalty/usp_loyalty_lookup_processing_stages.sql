CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_processing_stages]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('eligibility_check', 'Valida��o de elegibilidade', 1),
            ('event_creation',    'Cria��o de evento',          2),
            ('balance_rebuild',   'Rebuild de saldo',           3),
            ('score_rebuild',     'Rebuild de score',           4),
            ('finalization',      'Finaliza��o',                5)
    ) AS x(stage_code, stage_name, display_order)
    ORDER BY x.display_order;
END
GO


