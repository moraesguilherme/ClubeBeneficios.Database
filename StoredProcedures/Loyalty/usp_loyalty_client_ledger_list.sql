CREATE PROCEDURE [dbo].[usp_loyalty_client_ledger_list]
    @ClientId uniqueidentifier,
    @EventType varchar(50) = NULL,
    @MovementType varchar(30) = NULL,
    @SourceType varchar(50) = NULL,
    @DateFrom datetime2(7) = NULL,
    @DateTo datetime2(7) = NULL,
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
            e.id AS event_id,
            e.client_id,

            e.event_type,
            event_type_label =
                CASE e.event_type
                    WHEN 'payment_confirmed' THEN 'Pagamento confirmado'
                    WHEN 'service_consumed' THEN 'Serviço consumido'
                    WHEN 'reward_redemption' THEN 'Resgate de recompensa'
                    WHEN 'reward_reversal' THEN 'Estorno de recompensa'
                    WHEN 'points_expired' THEN 'Pontos expirados'
                    WHEN 'manual_adjustment' THEN 'Ajuste manual'
                    WHEN 'pet_birthday_bonus' THEN 'Bônus de aniversário'
                    WHEN 'referral_bonus' THEN 'Bônus por indicação'
                    WHEN 'signup_bonus' THEN 'Bônus de cadastro'
                    WHEN 'etl_import' THEN 'Importação de pontos'
                    WHEN 'custom' THEN 'Movimentação personalizada'
                    ELSE 'Movimentação'
                END,

            e.movement_type,
            movement_type_label =
                CASE e.movement_type
                    WHEN 'credit' THEN 'Crédito'
                    WHEN 'debit' THEN 'Débito'
                    WHEN 'expiration' THEN 'Expiração'
                    WHEN 'adjustment' THEN 'Ajuste'
                    WHEN 'reversal' THEN 'Estorno'
                    WHEN 'redemption_reserve' THEN 'Reserva de resgate'
                    WHEN 'redemption_commit' THEN 'Confirmação de resgate'
                    WHEN 'redemption_cancel' THEN 'Cancelamento de resgate'
                    ELSE 'Movimento'
                END,

            e.source_type,
            source_type_label =
                CASE e.source_type
                    WHEN 'etl_payment_row' THEN 'Pagamento de serviço'
                    WHEN 'etl_import' THEN 'Importação de pagamentos'
                    WHEN 'redemption' THEN 'Resgate'
                    WHEN 'adjustment' THEN 'Ajuste'
                    WHEN 'campaign' THEN 'Campanha'
                    WHEN 'manual' THEN 'Lançamento manual'
                    WHEN 'client' THEN 'Cliente'
                    WHEN 'client_pet' THEN 'Pet'
                    WHEN 'pet_birthday' THEN 'Aniversário do pet'
                    WHEN 'referral' THEN 'Indicação'
                    WHEN 'signup' THEN 'Cadastro'
                    WHEN 'benefit_request' THEN 'Solicitação de benefício'
                    WHEN 'benefit_usage' THEN 'Utilização de benefício'
                    WHEN 'custom' THEN 'Personalizado'
                    ELSE 'Origem não informada'
                END,

            e.source_id,
            e.source_reference,

            e.rule_id,
            lr.name AS rule_name,
            lr.description AS rule_description,

            e.campaign_id,
            lc.name AS campaign_name,

            e.reward_id,
            rw.title AS reward_title,

            e.adjustment_id,

            etl.service_type_raw AS service_type,
            etl.plan_name_raw AS plan_name,
            etl.package_name_raw AS package_name,
            etl.pet_name_raw AS pet_name,

            e.description,

            display_title =
                CASE e.event_type
                    WHEN 'payment_confirmed' THEN 'Pagamento confirmado'
                    WHEN 'service_consumed' THEN 'Serviço consumido'
                    WHEN 'reward_redemption' THEN 'Resgate de recompensa'
                    WHEN 'reward_reversal' THEN 'Estorno de recompensa'
                    WHEN 'points_expired' THEN 'Pontos expirados'
                    WHEN 'manual_adjustment' THEN 'Ajuste manual'
                    WHEN 'pet_birthday_bonus' THEN 'Bônus de aniversário'
                    WHEN 'referral_bonus' THEN 'Bônus por indicação'
                    WHEN 'signup_bonus' THEN 'Bônus de cadastro'
                    ELSE 'Movimentação de pontos'
                END,

            display_subtitle =
                CASE
                    WHEN e.event_type = 'payment_confirmed'
                         AND NULLIF(LTRIM(RTRIM(etl.service_type_raw)), '') IS NOT NULL
                         AND lr.name IS NOT NULL
                        THEN CONCAT(etl.service_type_raw, ' • ', lr.name)

                    WHEN e.event_type = 'payment_confirmed'
                         AND NULLIF(LTRIM(RTRIM(etl.service_type_raw)), '') IS NOT NULL
                        THEN CONCAT(etl.service_type_raw, ' • Pontuação aplicada')

                    WHEN e.event_type = 'payment_confirmed'
                         AND lr.name IS NOT NULL
                        THEN CONCAT('Pagamento de serviço • ', lr.name)

                    WHEN e.event_type = 'reward_redemption'
                         AND rw.title IS NOT NULL
                        THEN CONCAT(rw.title, ' • Recompensa resgatada')

                    WHEN e.event_type = 'reward_reversal'
                         AND rw.title IS NOT NULL
                        THEN CONCAT(rw.title, ' • Estorno de recompensa')

                    WHEN e.campaign_id IS NOT NULL
                         AND lc.name IS NOT NULL
                        THEN CONCAT('Campanha • ', lc.name)

                    WHEN e.rule_id IS NOT NULL
                         AND lr.name IS NOT NULL
                        THEN CONCAT('Regra • ', lr.name)

                    ELSE
                        CASE e.source_type
                            WHEN 'etl_payment_row' THEN 'Pagamento de serviço'
                            WHEN 'redemption' THEN 'Resgate'
                            WHEN 'adjustment' THEN 'Ajuste'
                            WHEN 'campaign' THEN 'Campanha'
                            ELSE 'Movimentação do programa'
                        END
                END,

            friendly_description =
                CASE
                    WHEN e.event_type = 'payment_confirmed'
                         AND NULLIF(LTRIM(RTRIM(etl.service_type_raw)), '') IS NOT NULL
                         AND lr.name IS NOT NULL
                        THEN CONCAT(
                            'Você ganhou ',
                            e.points_delta,
                            ' pontos pelo pagamento confirmado do serviço de ',
                            etl.service_type_raw,
                            '. Regra aplicada: ',
                            lr.name,
                            '.'
                        )

                    WHEN e.event_type = 'payment_confirmed'
                         AND NULLIF(LTRIM(RTRIM(etl.service_type_raw)), '') IS NOT NULL
                        THEN CONCAT(
                            'Você ganhou ',
                            e.points_delta,
                            ' pontos pelo pagamento confirmado do serviço de ',
                            etl.service_type_raw,
                            '.'
                        )

                    WHEN e.event_type = 'payment_confirmed'
                        THEN CONCAT(
                            'Você ganhou ',
                            e.points_delta,
                            ' pontos por um pagamento confirmado.'
                        )

                    WHEN e.event_type = 'reward_redemption'
                         AND rw.title IS NOT NULL
                        THEN CONCAT(
                            'Foram debitados ',
                            ABS(e.points_delta),
                            ' pontos pelo resgate da recompensa ',
                            rw.title,
                            '.'
                        )

                    WHEN e.event_type = 'reward_redemption'
                        THEN CONCAT(
                            'Foram debitados ',
                            ABS(e.points_delta),
                            ' pontos por um resgate de recompensa.'
                        )

                    WHEN e.event_type = 'reward_reversal'
                         AND rw.title IS NOT NULL
                        THEN CONCAT(
                            'Foram estornados pontos relacionados à recompensa ',
                            rw.title,
                            '.'
                        )

                    WHEN e.event_type = 'points_expired'
                        THEN 'Pontos expirados conforme as regras do programa de fidelidade.'

                    WHEN e.event_type = 'manual_adjustment'
                        THEN ISNULL(e.description, 'Ajuste de pontos realizado pela equipe da Matilha.')

                    WHEN e.event_type = 'pet_birthday_bonus'
                        THEN 'Pontos concedidos como bônus de aniversário do pet.'

                    WHEN e.event_type = 'referral_bonus'
                        THEN 'Pontos concedidos por indicação.'

                    WHEN e.event_type = 'signup_bonus'
                        THEN 'Pontos concedidos como bônus de cadastro.'

                    ELSE ISNULL(e.description, 'Movimentação registrada no programa de fidelidade.')
                END,

            e.points_delta,
            e.monetary_amount,

            e.payment_method,
            payment_method_label =
                CASE e.payment_method
                    WHEN 'pix' THEN 'Pix'
                    WHEN 'cash' THEN 'Dinheiro'
                    WHEN 'credit_card' THEN 'Cartão de crédito'
                    WHEN 'debit_card' THEN 'Cartão de débito'
                    WHEN 'bank_transfer' THEN 'Transferência bancária'
                    WHEN 'boleto' THEN 'Boleto'
                    WHEN 'other' THEN 'Outro'
                    ELSE NULL
                END,

            e.payment_reference,

            e.occurred_at AS event_date,
            e.effective_at,
            e.expires_at,
            e.is_expired,
            e.created_at
        FROM dbo.customer_loyalty_events e
        LEFT JOIN dbo.loyalty_rules lr
            ON lr.id = e.rule_id
        LEFT JOIN dbo.loyalty_campaigns lc
            ON lc.id = e.campaign_id
        LEFT JOIN dbo.loyalty_rewards rw
            ON rw.id = e.reward_id
        OUTER APPLY
        (
            SELECT TOP (1)
                ir.service_type_raw,
                ir.plan_name_raw,
                ir.package_name_raw,
                ir.pet_name_raw,
                ir.payment_method_raw,
                ir.gross_amount,
                ir.net_amount
            FROM dbo.etl_import_rows ir
            WHERE e.source_type = 'etl_payment_row'
              AND TRY_CONVERT(bigint, e.source_id) = ir.id
        ) etl
        WHERE e.client_id = @ClientId
          AND (@EventType IS NULL OR @EventType = '' OR e.event_type = @EventType)
          AND (@MovementType IS NULL OR @MovementType = '' OR e.movement_type = @MovementType)
          AND (@SourceType IS NULL OR @SourceType = '' OR e.source_type = @SourceType)
          AND (@DateFrom IS NULL OR e.occurred_at >= @DateFrom)
          AND (@DateTo IS NULL OR e.occurred_at < @DateTo)
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (ORDER BY event_date DESC, created_at DESC)
        FROM Filtered
    )
    SELECT
        event_id,
        client_id,

        event_type,
        event_type_label,

        movement_type,
        movement_type_label,

        source_type,
        source_type_label,

        source_id,
        source_reference,

        rule_id,
        rule_name,
        rule_description,

        campaign_id,
        campaign_name,

        reward_id,
        reward_title,

        adjustment_id,

        service_type,
        plan_name,
        package_name,
        pet_name,

        description,
        friendly_description,

        display_title,
        display_subtitle,

        points_delta,
        monetary_amount,

        payment_method,
        payment_method_label,
        payment_reference,

        event_date,
        effective_at,
        expires_at,
        is_expired,

        total_rows
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1)
                      AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO