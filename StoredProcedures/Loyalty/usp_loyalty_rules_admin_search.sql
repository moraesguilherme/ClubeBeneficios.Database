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
            conditions_count =
            (
                SELECT COUNT(1)
                FROM dbo.loyalty_rule_conditions rc
                WHERE rc.rule_id = r.id
            ),
			primary_condition_id =
			(
				SELECT TOP 1 rc.id
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			primary_condition_type =
			(
				SELECT TOP 1 rc.condition_type
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			primary_source_type =
			(
				SELECT TOP 1 rc.source_type
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			primary_service_type =
			(
				SELECT TOP 1 rc.service_type
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			primary_plan_type =
			(
				SELECT TOP 1 rc.plan_type
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			primary_package_type =
			(
				SELECT TOP 1 rc.package_type
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			primary_points_value =
			(
				SELECT TOP 1 rc.points_value
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			primary_currency_unit_amount =
			(
				SELECT TOP 1 rc.currency_unit_amount
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			primary_multiplier_value =
			(
				SELECT TOP 1 rc.multiplier_value
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			primary_window_type =
			(
				SELECT TOP 1 rc.window_type
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			primary_window_value =
			(
				SELECT TOP 1 rc.window_value
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			primary_payment_method =
			(
				SELECT TOP 1 rc.payment_method
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			primary_target_level_code =
			(
				SELECT TOP 1 rc.target_level_code
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			primary_json_payload =
			(
				SELECT TOP 1 rc.json_payload
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
				ORDER BY
					CASE
						WHEN rc.condition_type = r.category THEN 0
						ELSE 1
					END,
					rc.updated_at DESC,
					rc.created_at DESC
			),
			condition_summary =
			(
				SELECT TOP 1
					CONCAT(
						CASE rc.condition_type
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
							ELSE ISNULL(rc.condition_type, 'Condição')
						END,
						CASE
							WHEN rc.source_type IS NULL OR rc.source_type = '' THEN ''
							ELSE CONCAT(
								' · ',
								CASE rc.source_type
									WHEN 'etl_payment_row' THEN 'Pagamento importado'
									WHEN 'client' THEN 'Cliente'
									WHEN 'client_pet' THEN 'Cão'
									WHEN 'pet' THEN 'Cão'
									WHEN 'referral' THEN 'Indicação'
									WHEN 'manual' THEN 'Manual'
									ELSE rc.source_type
								END
							)
						END,
						CASE
							WHEN rc.payment_method IS NULL OR rc.payment_method = '' THEN ''
							ELSE CONCAT(' · ', UPPER(rc.payment_method))
						END,
						CASE
							WHEN rc.service_type IS NULL OR rc.service_type = '' THEN ''
							ELSE CONCAT(
								' · ',
								CASE rc.service_type
									WHEN 'creche' THEN 'Creche'
									WHEN 'hotel' THEN 'Hotel'
									ELSE rc.service_type
								END
							)
						END
					)
				FROM dbo.loyalty_rule_conditions rc
				WHERE rc.rule_id = r.id
					ORDER BY
						CASE
							WHEN rc.condition_type = r.category THEN 0
							ELSE 1
						END,
						rc.updated_at DESC,
						rc.created_at DESC
			)
        FROM dbo.loyalty_rules r
        INNER JOIN dbo.loyalty_rule_sets rs
            ON rs.id = r.rule_set_id
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