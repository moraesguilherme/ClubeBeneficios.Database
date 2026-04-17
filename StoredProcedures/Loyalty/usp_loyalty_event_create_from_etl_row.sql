CREATE PROCEDURE [dbo].[usp_loyalty_event_create_from_etl_row]
    @EventId uniqueidentifier,
    @ImportRowId bigint,
    @ClientId uniqueidentifier,
    @EventType varchar(50),
    @MovementType varchar(30),
    @PointsDelta int,
    @RuleId uniqueidentifier = NULL,
    @CampaignId uniqueidentifier = NULL,
    @PaymentReference varchar(150) = NULL,
    @Description varchar(1500) = NULL,
    @OccurredAt datetime2(7) = NULL,
    @EffectiveAt datetime2(7) = NULL,
    @ExpiresAt datetime2(7) = NULL,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RowOccurredAt datetime2(7);
    DECLARE @RowNetAmount decimal(18,2);
    DECLARE @RowPaymentMethod varchar(50);
    DECLARE @RowStatus varchar(30);
    DECLARE @MatchedClientId uniqueidentifier;

    SELECT
        @RowOccurredAt = r.occurred_at,
        @RowNetAmount = r.net_amount,
        @RowPaymentMethod = r.payment_method_normalized,
        @RowStatus = r.status,
        @MatchedClientId = m.client_id
    FROM dbo.etl_import_rows r
    LEFT JOIN dbo.etl_import_row_matches m
        ON m.import_row_id = r.id
    WHERE r.id = @ImportRowId;

    IF @RowStatus IS NULL
    BEGIN
        RAISERROR('Linha ETL nao encontrada.', 16, 1);
        RETURN;
    END

    IF @RowStatus NOT IN ('matched', 'processed')
    BEGIN
        RAISERROR('Linha ETL nao esta apta para gerar evento de fidelidade.', 16, 1);
        RETURN;
    END

    IF @MatchedClientId IS NULL
    BEGIN
        RAISERROR('Linha ETL sem client_id reconciliado.', 16, 1);
        RETURN;
    END

    IF @MatchedClientId <> @ClientId
    BEGIN
        RAISERROR('ClientId informado difere do client_id reconciliado na ETL.', 16, 1);
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.customer_loyalty_events
        WHERE source_type = 'etl_payment_row'
          AND source_id = CONVERT(varchar(100), @ImportRowId)
    )
    BEGIN
        RAISERROR('Ja existe evento de fidelidade para esta linha ETL.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.customer_loyalty_events
    (
        id,
        client_id,
        event_type,
        movement_type,
        source_type,
        source_id,
        rule_id,
        campaign_id,
        reward_id,
        adjustment_id,
        points_delta,
        monetary_amount,
        payment_method,
        payment_reference,
        occurred_at,
        effective_at,
        expires_at,
        is_expired,
        description,
        created_at,
        created_by_user_id
    )
    VALUES
    (
        @EventId,
        @ClientId,
        @EventType,
        @MovementType,
        'etl_payment_row',
        CONVERT(varchar(100), @ImportRowId),
        @RuleId,
        @CampaignId,
        NULL,
        NULL,
        @PointsDelta,
        @RowNetAmount,
        @RowPaymentMethod,
        @PaymentReference,
        ISNULL(@OccurredAt, ISNULL(@RowOccurredAt, SYSUTCDATETIME())),
        ISNULL(@EffectiveAt, ISNULL(@RowOccurredAt, SYSUTCDATETIME())),
        @ExpiresAt,
        0,
        @Description,
        SYSUTCDATETIME(),
        @CreatedByUserId
    );

    --UPDATE dbo.etl_import_rows
    --SET
    --    status = 'processed',
    --    processed_at = ISNULL(processed_at, SYSUTCDATETIME())
    --WHERE id = @ImportRowId;

    SELECT *
    FROM dbo.customer_loyalty_events
    WHERE id = @EventId;
END

GO


