CREATE   PROCEDURE [dbo].[usp_loyalty_calculate_points_for_etl_row]
    @ImportRowId bigint
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @ClientId uniqueidentifier,
        @NetAmount decimal(18,2),
        @GrossAmount decimal(18,2),
        @PaymentMethod varchar(50),
        @ServiceType varchar(50),
        @PlanType varchar(100),
        @PackageType varchar(100),
        @Status varchar(30);

    SELECT
        @ClientId = m.client_id,
        @NetAmount = r.net_amount,
        @GrossAmount = r.gross_amount,
        @PaymentMethod = r.payment_method_normalized,
        @ServiceType = r.service_type,
        @PlanType = r.plan_type,
        @PackageType = r.package_type,
        @Status = r.status
    FROM dbo.etl_import_rows r
    INNER JOIN dbo.etl_import_row_matches m
        ON m.import_row_id = r.id
    WHERE r.id = @ImportRowId;

    IF @ClientId IS NULL
    BEGIN
        RAISERROR('Linha ETL sem client_id reconciliado.', 16, 1);
        RETURN;
    END;

    IF @Status NOT IN ('matched', 'processed')
    BEGIN
        RAISERROR('Linha ETL nao esta apta para pontuacao.', 16, 1);
        RETURN;
    END;

    ;WITH ActiveRules AS
    (
        SELECT
            r.id AS rule_id,
            r.name AS rule_name,
            r.calculation_type,
            rc.id AS condition_id,
            rc.condition_type,
            rc.source_type,
            rc.service_type,
            rc.plan_type,
            rc.package_type,
            rc.payment_method,
            rc.min_amount,
            rc.max_amount,
            rc.points_value,
            rc.currency_unit_amount,
            rc.multiplier_value
        FROM dbo.loyalty_rules r
        INNER JOIN dbo.loyalty_rule_conditions rc
            ON rc.rule_id = r.id
        WHERE r.status = 'active'
          AND r.category IN ('scoring', 'points')
          AND (r.valid_from IS NULL OR r.valid_from <= SYSUTCDATETIME())
          AND (r.valid_to IS NULL OR r.valid_to >= SYSUTCDATETIME())
          AND ISNULL(rc.source_type, 'etl_payment_row') = 'etl_payment_row'
    ),
    MatchedRules AS
    (
        SELECT
            ar.rule_id,
            ar.rule_name,
            ar.calculation_type,
            ar.condition_id,
            ar.points_value,
            ar.currency_unit_amount,
            ar.multiplier_value,
            base_amount = ISNULL(@NetAmount, ISNULL(@GrossAmount, 0))
        FROM ActiveRules ar
        WHERE
            (@ServiceType IS NULL OR ar.service_type IS NULL OR ar.service_type = @ServiceType)
            AND (@PlanType IS NULL OR ar.plan_type IS NULL OR ar.plan_type = @PlanType)
            AND (@PackageType IS NULL OR ar.package_type IS NULL OR ar.package_type = @PackageType)
            AND (@PaymentMethod IS NULL OR ar.payment_method IS NULL OR ar.payment_method = @PaymentMethod)
            AND (ar.min_amount IS NULL OR ISNULL(@NetAmount, ISNULL(@GrossAmount, 0)) >= ar.min_amount)
            AND (ar.max_amount IS NULL OR ISNULL(@NetAmount, ISNULL(@GrossAmount, 0)) <= ar.max_amount)
    )
    SELECT
        import_row_id = @ImportRowId,
        client_id = @ClientId,
        rule_id,
        rule_name,
        condition_id,
        calculation_type,
        points_delta =
            CAST(
                CASE
                    WHEN calculation_type = 'fixed_points'
                        THEN ISNULL(points_value, 0)

                    WHEN calculation_type = 'per_currency'
                        THEN
                            CASE
                                WHEN ISNULL(currency_unit_amount, 0) <= 0 THEN 0
                                ELSE FLOOR((base_amount / currency_unit_amount) * ISNULL(points_value, 1))
                            END

                    WHEN calculation_type = 'multiplier'
                        THEN FLOOR(base_amount * ISNULL(multiplier_value, 1))

                    ELSE 0
                END
            AS int),
        description =
            CONCAT(
                'Regra aplicada: ',
                rule_name,
                ' | Valor base: ',
                CONVERT(varchar(50), base_amount)
            )
    FROM MatchedRules
    WHERE
        CAST(
            CASE
                WHEN calculation_type = 'fixed_points'
                    THEN ISNULL(points_value, 0)

                WHEN calculation_type = 'per_currency'
                    THEN
                        CASE
                            WHEN ISNULL(currency_unit_amount, 0) <= 0 THEN 0
                            ELSE FLOOR((base_amount / currency_unit_amount) * ISNULL(points_value, 1))
                        END

                WHEN calculation_type = 'multiplier'
                    THEN FLOOR(base_amount * ISNULL(multiplier_value, 1))

                ELSE 0
            END
        AS int) <> 0;
END;
GO

