CREATE   PROCEDURE [dbo].[usp_loyalty_redemption_schedule]
    @RedemptionId uniqueidentifier,
    @ScheduledFor datetime2(7),
    @DecisionNotes varchar(1500) = NULL,
    @DecidedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentStatus varchar(30);

    SELECT @CurrentStatus = status
    FROM dbo.loyalty_redemptions
    WHERE id = @RedemptionId;

    IF @CurrentStatus IS NULL
    BEGIN
        RAISERROR('Resgate nao encontrado.', 16, 1);
        RETURN;
    END

    IF @CurrentStatus NOT IN ('approved')
    BEGIN
        RAISERROR('Somente resgates aprovados podem ser agendados.', 16, 1);
        RETURN;
    END

    IF @ScheduledFor IS NULL
    BEGIN
        RAISERROR('A data de agendamento e obrigatoria.', 16, 1);
        RETURN;
    END

    UPDATE dbo.loyalty_redemptions
    SET
        scheduled_for = @ScheduledFor,
        internal_notes = @DecisionNotes,
        decided_by_user_id = @DecidedByUserId,
        updated_at = SYSUTCDATETIME()
    WHERE id = @RedemptionId;

    SELECT *
    FROM dbo.loyalty_redemptions
    WHERE id = @RedemptionId;
END
GO

