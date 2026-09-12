CREATE PROCEDURE [dbo].[usp_loyalty_customer_rewards_available_list]
    @ClientId uniqueidentifier,
    @Search varchar(150) = NULL,
    @PageNumber int = 1,
    @PageSize int = 12
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 12;

    DECLARE @ClientLevelCode varchar(30);
    DECLARE @AvailablePoints int;

    SELECT TOP (1)
        @ClientLevelCode = COALESCE(m.level_code, h.to_level_code)
    FROM dbo.clients c
    OUTER APPLY
    (
        SELECT TOP (1)
            s.level_code
        FROM dbo.customer_loyalty_metric_snapshots s
        WHERE s.client_id = c.id
        ORDER BY s.calculated_at DESC, s.created_at DESC
    ) m
    OUTER APPLY
    (
        SELECT TOP (1)
            lh.to_level_code
        FROM dbo.loyalty_level_history lh
        WHERE lh.client_id = c.id
        ORDER BY lh.changed_at DESC, lh.created_at DESC
    ) h
    WHERE c.id = @ClientId;

    SELECT
        @AvailablePoints = ISNULL(b.available_points, 0)
    FROM dbo.customer_loyalty_balances b
    WHERE b.client_id = @ClientId;

    SET @ClientLevelCode = ISNULL(@ClientLevelCode, 'bronze');
    SET @AvailablePoints = ISNULL(@AvailablePoints, 0);

    ;WITH LevelRank AS
    (
        SELECT 'bronze' AS level_code, 1 AS level_rank
        UNION ALL SELECT 'silver', 2
        UNION ALL SELECT 'gold', 3
        UNION ALL SELECT 'diamond', 4
    ),
    ClientLevel AS
    (
        SELECT
            ISNULL(lr.level_rank, 1) AS level_rank
        FROM (SELECT @ClientLevelCode AS level_code) x
        LEFT JOIN LevelRank lr
            ON lr.level_code = x.level_code
    ),
    Filtered AS
    (
        SELECT
            r.id,
            r.title,
            r.description,
            r.points_cost,
            r.availability_summary,
            r.operational_rule_summary,
            r.eligible_level_code,
            r.redemption_mode,
            r.minimum_notice_hours,
            r.cumulative_mode,
            r.usage_window_type,
            r.usage_window_value,
            r.availability_type,
            r.season_type,
            r.is_transferable,

            eligible_level_name =
                CASE r.eligible_level_code
                    WHEN 'bronze' THEN 'Bronze'
                    WHEN 'silver' THEN 'Prata'
                    WHEN 'gold' THEN 'Ouro'
                    WHEN 'diamond' THEN 'Diamante'
                    ELSE 'Livre'
                END,

            redemption_mode_label =
                CASE r.redemption_mode
                    WHEN 'automatic' THEN 'Resgate automático'
                    WHEN 'approval_required' THEN 'Exige aprovação'
                    WHEN 'manual_review' THEN 'Análise manual'
                    ELSE 'Não informado'
                END,

            cumulative_mode_label =
                CASE r.cumulative_mode
                    WHEN 'cumulative' THEN 'Pode acumular com outras recompensas'
                    WHEN 'non_cumulative' THEN 'Não cumulativo'
                    ELSE 'Não informado'
                END,

            usage_window_label =
                CASE
                    WHEN r.usage_window_type IS NULL THEN 'Uso conforme regra da recompensa'
                    WHEN r.usage_window_value IS NULL THEN
                        CASE r.usage_window_type
                            WHEN 'day' THEN 'Uso diário'
                            WHEN 'week' THEN 'Uso semanal'
                            WHEN 'month' THEN 'Uso mensal'
                            WHEN 'quarter' THEN 'Uso trimestral'
                            WHEN 'semester' THEN 'Uso semestral'
                            WHEN 'year' THEN 'Uso anual'
                            ELSE 'Uso conforme regra da recompensa'
                        END
                    ELSE CONCAT(
                        r.usage_window_value,
                        'x por ',
                        CASE r.usage_window_type
                            WHEN 'day' THEN 'dia'
                            WHEN 'week' THEN 'semana'
                            WHEN 'month' THEN 'mês'
                            WHEN 'quarter' THEN 'trimestre'
                            WHEN 'semester' THEN 'semestre'
                            WHEN 'year' THEN 'ano'
                            ELSE r.usage_window_type
                        END
                    )
                END,

            availability_label =
                CASE r.availability_type
                    WHEN 'general' THEN 'Disponível conforme regras do programa'
                    WHEN 'limited' THEN 'Disponibilidade limitada'
                    WHEN 'seasonal' THEN 'Disponível em períodos específicos'
                    ELSE 'Disponibilidade conforme regra da recompensa'
                END,

            season_label =
                CASE r.season_type
                    WHEN 'all' THEN 'Disponível o ano todo'
                    WHEN 'low_season' THEN 'Válida em baixa temporada'
                    WHEN 'high_season' THEN 'Válida em alta temporada'
                    WHEN 'holiday' THEN 'Válida em feriados'
                    ELSE 'Sem restrição de temporada informada'
                END,

            transferable_label =
                CASE
                    WHEN r.is_transferable = 1 THEN 'Pode ser transferida conforme regra da recompensa'
                    ELSE 'Uso exclusivo do cliente titular'
                END,

            has_enough_points =
                CASE
                    WHEN @AvailablePoints >= r.points_cost THEN CAST(1 AS bit)
                    ELSE CAST(0 AS bit)
                END,

            is_level_eligible =
                CASE
                    WHEN r.eligible_level_code IS NULL THEN CAST(1 AS bit)
                    WHEN reward_level.level_rank IS NULL THEN CAST(1 AS bit)
                    WHEN client_level.level_rank >= reward_level.level_rank THEN CAST(1 AS bit)
                    ELSE CAST(0 AS bit)
                END,

            has_active_redemption =
                CASE
                    WHEN active_redemption.id IS NOT NULL THEN CAST(1 AS bit)
                    ELSE CAST(0 AS bit)
                END,

            active_redemption_id = active_redemption.id,
            active_redemption_status = active_redemption.status,
            active_redemption_requested_at = active_redemption.requested_at

        FROM dbo.loyalty_rewards r
        CROSS JOIN ClientLevel client_level
        LEFT JOIN LevelRank reward_level
            ON reward_level.level_code = r.eligible_level_code

        OUTER APPLY
        (
            SELECT TOP (1)
                lr.id,
                lr.status,
                lr.requested_at
            FROM dbo.loyalty_redemptions lr
            WHERE lr.client_id = @ClientId
              AND lr.reward_id = r.id
              AND lr.status IN ('requested', 'under_review', 'approved')
            ORDER BY lr.requested_at DESC
        ) active_redemption

        WHERE r.status = 'active'
          AND (
                @Search IS NULL
                OR LTRIM(RTRIM(@Search)) = ''
                OR r.title LIKE '%' + @Search + '%'
                OR r.description LIKE '%' + @Search + '%'
                OR r.availability_summary LIKE '%' + @Search + '%'
                OR r.operational_rule_summary LIKE '%' + @Search + '%'
              )
    ),
    Result AS
    (
        SELECT
            *,

            can_redeem =
                CASE
                    WHEN has_active_redemption = 1 THEN CAST(0 AS bit)
                    WHEN has_enough_points = 1 AND is_level_eligible = 1 THEN CAST(1 AS bit)
                    ELSE CAST(0 AS bit)
                END,

            unavailable_reason =
                CASE
                    WHEN has_active_redemption = 1 THEN 'Você já possui uma solicitação ativa para esta recompensa.'
                    WHEN has_enough_points = 0 THEN 'Você ainda não possui pontos suficientes para solicitar esta recompensa.'
                    WHEN is_level_eligible = 0 THEN 'Seu nível atual ainda não libera esta recompensa.'
                    ELSE NULL
                END,

            display_title =
                CASE
                    WHEN NULLIF(LTRIM(RTRIM(title)), '') IS NOT NULL THEN title
                    ELSE 'Recompensa do Clube Matilha'
                END,

            display_description =
                CASE
                    WHEN NULLIF(LTRIM(RTRIM(description)), '') IS NOT NULL THEN description
                    WHEN NULLIF(LTRIM(RTRIM(availability_summary)), '') IS NOT NULL THEN availability_summary
                    ELSE 'Use seus pontos para solicitar esta recompensa no Clube Matilha.'
                END,

            display_subtitle =
                CONCAT(
                    points_cost,
                    ' pontos',
                    ' • ',
                    CASE
                        WHEN eligible_level_code IS NULL THEN 'Livre para todos os níveis'
                        ELSE CONCAT('A partir do nível ', eligible_level_name)
                    END
                ),

            customer_usage_summary =
                CASE
                    WHEN redemption_mode = 'automatic'
                        THEN 'A solicitação pode ser processada automaticamente, conforme as regras da recompensa.'
                    WHEN redemption_mode = 'approval_required'
                        THEN 'Após solicitar, aguarde a aprovação da equipe Matilha.'
                    WHEN redemption_mode = 'manual_review'
                        THEN 'Sua solicitação será analisada pela equipe Matilha antes da liberação.'
                    ELSE 'Solicite pelo portal e acompanhe o andamento em Meus resgates.'
                END,

            eligibility_label =
                CASE
                    WHEN eligible_level_code IS NULL THEN 'Disponível para todos os níveis'
                    ELSE CONCAT('Disponível para clientes nível ', eligible_level_name, ' ou superior')
                END,

            status_label =
                CASE
                    WHEN has_active_redemption = 1 THEN 'Já solicitado'
                    WHEN has_enough_points = 1 AND is_level_eligible = 1 THEN 'Disponível para solicitar'
                    WHEN has_enough_points = 0 THEN 'Pontos insuficientes'
                    WHEN is_level_eligible = 0 THEN 'Nível insuficiente'
                    ELSE 'Indisponível'
                END,

            status_description =
                CASE
                    WHEN has_active_redemption = 1
                        THEN 'Você já possui uma solicitação em andamento para esta recompensa.'
                    WHEN has_enough_points = 1 AND is_level_eligible = 1
                        THEN 'Você atende aos requisitos atuais para solicitar esta recompensa.'
                    WHEN has_enough_points = 0
                        THEN 'Você ainda precisa acumular mais pontos para solicitar esta recompensa.'
                    WHEN is_level_eligible = 0
                        THEN 'Seu nível atual ainda não permite solicitar esta recompensa.'
                    ELSE 'Esta recompensa não está disponível para solicitação no momento.'
                END,

            action_label =
                CASE
                    WHEN has_active_redemption = 1 THEN 'Resgate já solicitado'
                    WHEN has_enough_points = 1 AND is_level_eligible = 1 THEN 'Solicitar recompensa'
                    ELSE 'Indisponível'
                END,

            total_rows = COUNT(1) OVER(),

            row_num = ROW_NUMBER() OVER (
                ORDER BY
                    CASE
                        WHEN has_active_redemption = 1 THEN 1
                        WHEN has_enough_points = 1 AND is_level_eligible = 1 THEN 0
                        ELSE 2
                    END,
                    points_cost ASC,
                    title ASC
            )
        FROM Filtered
    )
    SELECT
        id,
        title,
        description,
        points_cost,
        availability_summary,
        operational_rule_summary,

        eligible_level_code,
        eligible_level_name,

        redemption_mode,
        redemption_mode_label,

        minimum_notice_hours,

        cumulative_mode,
        cumulative_mode_label,

        usage_window_type,
        usage_window_value,
        usage_window_label,

        availability_type,
        availability_label,

        season_type,
        season_label,

        is_transferable,
        transferable_label,

        has_enough_points,
        is_level_eligible,

        has_active_redemption,
        active_redemption_id,
        active_redemption_status,
        active_redemption_requested_at,

        can_redeem,
        unavailable_reason,

        display_title,
        display_description,
        display_subtitle,
        customer_usage_summary,
        eligibility_label,
        status_label,
        status_description,
        action_label,

        total_rows
    FROM Result
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1)
                      AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO