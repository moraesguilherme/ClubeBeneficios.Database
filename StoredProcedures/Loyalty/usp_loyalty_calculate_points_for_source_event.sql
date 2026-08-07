CREATE   PROCEDURE [dbo].[usp_loyalty_calculate_points_for_source_event]
    @ClientId uniqueidentifier,
    @SourceType varchar(50),
    @ConditionType varchar(50),
    @SourceId varchar(100),
    @SourceReference varchar(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH ActiveRules AS
    (
        SELECT
            r.id AS rule_id,
            r.name AS rule_name,
            r.calculation_type,
            rc.id AS condition_id,
            rc.condition_type,
            rc.source_type,
            rc.points_value,
            rc.currency_unit_amount,
            rc.multiplier_value,
            rc.window_type,
            rc.window_value
        FROM dbo.loyalty_rules r
        INNER JOIN dbo.loyalty_rule_conditions rc
            ON rc.rule_id = r.id
        WHERE r.status = 'active'
          AND r.category IN ('scoring', 'points')
          AND (r.valid_from IS NULL OR r.valid_from <= SYSUTCDATETIME())
          AND (r.valid_to IS NULL OR r.valid_to >= SYSUTCDATETIME())
          AND rc.source_type = @SourceType
          AND rc.condition_type = @ConditionType
    )
    SELECT
        client_id = @ClientId,
        source_type = @SourceType,
        source_id = @SourceId,
        source_reference = @SourceReference,
        rule_id,
        rule_name,
        condition_id,
        calculation_type,
        points_delta =
            CAST(
                CASE
                    WHEN calculation_type = 'fixed_points'
                        THEN ISNULL(points_value, 0)
                    ELSE 0
                END
            AS int),
        description =
            CONCAT(
                'Regra aplicada: ',
                rule_name,
                ' | Origem: ',
                @SourceType,
                ' | Condicao: ',
                @ConditionType
            )
    FROM ActiveRules
    WHERE
        CAST(
            CASE
                WHEN calculation_type = 'fixed_points'
                    THEN ISNULL(points_value, 0)
                ELSE 0
            END
        AS int) <> 0;
END;
GO

