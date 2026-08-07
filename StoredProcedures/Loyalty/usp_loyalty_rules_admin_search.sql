CREATE   PROCEDURE [dbo].[usp_loyalty_rules_admin_search]
    @Search varchar(150) = NULL,
    @RuleSetId uniqueidentifier = NULL,
    @Category varchar(50) = NULL,
    @Status varchar(30) = NULL,
    @PageNumber int = 1,
    @PageSize int = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 20;

    ;WITH Filtered AS
    (
        SELECT
            r.id,
            r.rule_set_id,
            rs.name AS rule_set_name,
            r.name,
            r.category,
            r.description,
            r.calculation_type,
            r.stacking_mode,
            r.status,
            r.priority,
            r.valid_from,
            r.valid_to,
            r.created_at,
            r.updated_at,
            conditions_count = ISNULL(cc.conditions_count, 0),

            primary_condition_id = pc.id,
            primary_condition_type = pc.condition_type,
            primary_source_type = pc.source_type,
            primary_service_type = pc.service_type,
            primary_plan_type = pc.plan_type,
            primary_package_type = pc.package_type,
            primary_points_value = pc.points_value,
            primary_currency_unit_amount = pc.currency_unit_amount,
            primary_multiplier_value = pc.multiplier_value,
            primary_window_type = pc.window_type,
            primary_window_value = pc.window_value,
            primary_payment_method = pc.payment_method,
            primary_target_level_code = pc.target_level_code,
            primary_json_payload = pc.json_payload,

            condition_summary =
                CASE
                    WHEN pc.id IS NULL THEN NULL
                    ELSE CONCAT(
                        CASE pc.condition_type
                            WHEN 'paid_amount' THEN 'Valor pago'
                            WHEN 'payment_method' THEN 'Forma de pagamento'
                            WHEN 'service_type' THEN 'Tipo de serviço'
                            WHEN 'plan_type' THEN 'Plano contratado'
                            WHEN 'package_type' THEN 'Pacote contratado'
                            WHEN 'client_birthday' THEN 'Aniversário do tutor'
                            WHEN 'tutor_birthday' THEN 'Aniversário do tutor'
                            WHEN 'pet_birthday' THEN 'Aniversário do cão'
                            WHEN 'pet_created' THEN 'Novo cão cadastrado'
                            WHEN 'new_pet' THEN 'Novo cão cadastrado'
                            WHEN 'new_client' THEN 'Novo cliente'
                            WHEN 'referral' THEN 'Indicação'
                            WHEN 'custom' THEN 'Personalizada'
                            ELSE ISNULL(pc.condition_type, 'Condição')
                        END,
                        CASE
                            WHEN pc.source_type IS NULL OR pc.source_type = '' THEN ''
                            ELSE CONCAT(
                                ' · ',
                                CASE pc.source_type
                                    WHEN 'etl_payment_row' THEN 'Pagamento importado'
                                    WHEN 'client' THEN 'Cliente'
                                    WHEN 'client_pet' THEN 'Cão'
                                    WHEN 'pet' THEN 'Cão'
                                    WHEN 'referral' THEN 'Indicação'
                                    WHEN 'manual' THEN 'Manual'
                                    ELSE pc.source_type
                                END
                            )
                        END,
                        CASE
                            WHEN pc.payment_method IS NULL OR pc.payment_method = '' THEN ''
                            ELSE CONCAT(' · ', UPPER(pc.payment_method))
                        END,
                        CASE
                            WHEN pc.service_type IS NULL OR pc.service_type = '' THEN ''
                            ELSE CONCAT(
                                ' · ',
                                CASE pc.service_type
                                    WHEN 'creche' THEN 'Creche'
                                    WHEN 'hotel' THEN 'Hotel'
                                    ELSE pc.service_type
                                END
                            )
                        END
                    )
                END
        FROM dbo.loyalty_rules r
        INNER JOIN dbo.loyalty_rule_sets rs
            ON rs.id = r.rule_set_id

        OUTER APPLY
        (
            SELECT COUNT(1) AS conditions_count
            FROM dbo.loyalty_rule_conditions rc
            WHERE rc.rule_id = r.id
        ) cc

        OUTER APPLY
        (
            SELECT TOP 1
                rc.id,
                rc.condition_type,
                rc.source_type,
                rc.service_type,
                rc.plan_type,
                rc.package_type,
                rc.points_value,
                rc.currency_unit_amount,
                rc.multiplier_value,
                rc.window_type,
                rc.window_value,
                rc.payment_method,
                rc.target_level_code,
                rc.json_payload,
                rc.updated_at,
                rc.created_at
            FROM dbo.loyalty_rule_conditions rc
            WHERE rc.rule_id = r.id
            ORDER BY
                CASE
                    WHEN rc.condition_type = r.category THEN 0
                    ELSE 1
                END,
                rc.updated_at DESC,
                rc.created_at DESC
        ) pc

        WHERE (@Search IS NULL OR LTRIM(RTRIM(@Search)) = '' OR r.name LIKE '%' + @Search + '%' OR r.description LIKE '%' + @Search + '%')
          AND (@RuleSetId IS NULL OR r.rule_set_id = @RuleSetId)
          AND (@Category IS NULL OR @Category = '' OR r.category = @Category)
          AND (@Status IS NULL OR @Status = '' OR r.status = @Status)
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY priority DESC, updated_at DESC, name ASC)
        FROM Filtered
    )
    SELECT
        id,
        rule_set_id,
        rule_set_name,
        name,
        category,
        description,
        calculation_type,
        stacking_mode,
        status,
        priority,
        valid_from,
        valid_to,
        created_at,
        updated_at,
        conditions_count,
        primary_condition_id,
        primary_condition_type,
        primary_source_type,
        primary_service_type,
        primary_payment_method,
        primary_plan_type,
        primary_package_type,
        primary_target_level_code,
        primary_points_value,
        primary_currency_unit_amount,
        primary_multiplier_value,
        primary_window_type,
        primary_window_value,
        primary_json_payload,
        condition_summary,
        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO

