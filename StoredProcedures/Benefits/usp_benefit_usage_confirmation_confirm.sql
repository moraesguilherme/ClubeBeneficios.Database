CREATE   PROCEDURE [dbo].[usp_benefit_usage_confirmation_confirm]
    @TokenHash VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    DECLARE
        @ConfirmationId UNIQUEIDENTIFIER,
        @BenefitRequestId UNIQUEIDENTIFIER,
        @BenefitUsageId UNIQUEIDENTIFIER,
        @ConfirmationType VARCHAR(30),
        @ConfirmationStatus VARCHAR(30),
        @ExpiresAt DATETIME2(7),
        @TimelineDescription VARCHAR(1500);

    SELECT
        @ConfirmationId = id,
        @BenefitRequestId = benefit_request_id,
        @BenefitUsageId = benefit_usage_id,
        @ConfirmationType = confirmation_type,
        @ConfirmationStatus = confirmation_status,
        @ExpiresAt = expires_at
    FROM dbo.benefit_usage_confirmations
    WHERE token_hash = @TokenHash;

    IF @ConfirmationId IS NULL
    BEGIN
        RAISERROR('Confirmação não encontrada.', 16, 1);
        RETURN;
    END

    IF @ConfirmationStatus = 'confirmed'
    BEGIN
        SELECT
            @ConfirmationId AS confirmation_id,
            @BenefitRequestId AS benefit_request_id,
            @ConfirmationType AS confirmation_type,
            'already_confirmed' AS result,
            @BenefitUsageId AS benefit_usage_id;
        RETURN;
    END

    IF @ConfirmationStatus IN ('rejected', 'expired', 'cancelled')
    BEGIN
        RAISERROR('Esta confirmação não está mais disponível.', 16, 1);
        RETURN;
    END

    IF @ExpiresAt < @Now
    BEGIN
        UPDATE dbo.benefit_usage_confirmations
        SET
            confirmation_status = 'expired',
            updated_at = @Now
        WHERE id = @ConfirmationId;

        RAISERROR('Link de confirmação expirado.', 16, 1);
        RETURN;
    END

    SET @TimelineDescription =
        CASE
            WHEN @ConfirmationType = 'client'
                THEN 'Cliente confirmou a utilização do benefício.'
            WHEN @ConfirmationType = 'partner'
                THEN 'Parceiro confirmou a utilização do benefício.'
            ELSE 'Confirmação de utilização registrada.'
        END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.benefit_usage_confirmations
        SET
            confirmation_status = 'confirmed',
            confirmed_at = @Now,
            updated_at = @Now
        WHERE id = @ConfirmationId
          AND confirmation_status = 'pending';

        EXEC dbo.usp_benefit_request_timeline_event_add
            @BenefitRequestId = @BenefitRequestId,
            @EventType = 'usage_confirmation_received',
            @EventStatus = NULL,
            @EventPoint = 'usage_confirmation',
            @EventDescription = @TimelineDescription,
            @ActorUserId = NULL,
            @OccurredAt = @Now;

        COMMIT TRANSACTION;

        SELECT
            @ConfirmationId AS confirmation_id,
            @BenefitRequestId AS benefit_request_id,
            @ConfirmationType AS confirmation_type,
            'confirmed' AS result,
            @BenefitUsageId AS benefit_usage_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO

