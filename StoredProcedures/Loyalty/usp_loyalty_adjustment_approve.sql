CREATE   PROCEDURE [dbo].[usp_loyalty_adjustment_approve]
    @AdjustmentId uniqueidentifier,
    @DecisionNotes varchar(1500) = NULL,
    @DecidedByUserId uniqueidentifier = NULL,
    @LedgerEventId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ClientId uniqueidentifier;
    DECLARE @CurrentStatus varchar(30);
    DECLARE @ImpactType varchar(30);
    DECLARE @AdjustmentType varchar(50);
    DECLARE @PointsDelta int;

    SELECT
        @ClientId = a.client_id,
        @CurrentStatus = a.status,
        @ImpactType = a.impact_type,
        @AdjustmentType = a.adjustment_type,
        @PointsDelta = a.points_delta
    FROM dbo.loyalty_adjustments a
    WHERE a.id = @AdjustmentId;

    IF @CurrentStatus IS NULL
    BEGIN
        RAISERROR('Ajuste nao encontrado.', 16, 1);
        RETURN;
    END

    IF @CurrentStatus <> 'pending'
    BEGIN
        RAISERROR('Somente ajustes pendentes podem ser aprovados.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

        IF @ImpactType IN ('points', 'mixed')
        BEGIN
            IF @PointsDelta IS NULL OR @PointsDelta = 0
            BEGIN
                RAISERROR('Ajuste com impacto em pontos exige points_delta diferente de zero.', 16, 1);
                ROLLBACK TRAN;
                RETURN;
            END

            IF @PointsDelta < 0
            BEGIN
                DECLARE @AvailablePoints int;

                SELECT
                    @AvailablePoints = ISNULL(available_points, 0)
                FROM dbo.customer_loyalty_balances
                WHERE client_id = @ClientId;

                SET @AvailablePoints = ISNULL(@AvailablePoints, 0);

                IF @AvailablePoints + @PointsDelta < 0
                BEGIN
                    RAISERROR('Saldo insuficiente para aprovar este ajuste de debito.', 16, 1);
                    ROLLBACK TRAN;
                    RETURN;
                END
            END
        END

        UPDATE dbo.loyalty_adjustments
        SET
            status = 'approved',
            decision_notes = @DecisionNotes,
            decided_at = SYSUTCDATETIME(),
            decided_by_user_id = @DecidedByUserId,
            updated_at = SYSUTCDATETIME()
        WHERE id = @AdjustmentId;

        IF @ImpactType IN ('points', 'mixed')
        BEGIN
            IF @LedgerEventId IS NULL
                SET @LedgerEventId = NEWID();

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
                @LedgerEventId,
                @ClientId,
                'manual_adjustment',
                CASE WHEN @PointsDelta > 0 THEN 'credit' ELSE 'debit' END,
                'adjustment',
                @AdjustmentId,
                NULL,
                NULL,
                NULL,
                @AdjustmentId,
                @PointsDelta,
                NULL,
                NULL,
                NULL,
                SYSUTCDATETIME(),
                SYSUTCDATETIME(),
                NULL,
                0,
                CONCAT('Ajuste aprovado: ', @AdjustmentType),
                SYSUTCDATETIME(),
                @DecidedByUserId
            );

            EXEC dbo.usp_customer_loyalty_balance_rebuild
                @ClientId = @ClientId;
        END

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        THROW;
    END CATCH;

    SELECT *
    FROM dbo.loyalty_adjustments
    WHERE id = @AdjustmentId;
END
GO

