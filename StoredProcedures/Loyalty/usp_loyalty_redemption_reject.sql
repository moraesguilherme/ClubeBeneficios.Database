CREATE   PROCEDURE [dbo].[usp_loyalty_redemption_reject]
    @RedemptionId uniqueidentifier,
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

    IF @CurrentStatus NOT IN ('requested', 'under_review')
    BEGIN
        RAISERROR('Somente resgates em requested/under_review podem ser rejeitados.', 16, 1);
        RETURN;
    END

    UPDATE dbo.loyalty_redemptions
    SET
        status = 'rejected',
        rejected_at = SYSUTCDATETIME(),
        internal_notes = @DecisionNotes,
        decided_by_user_id = @DecidedByUserId,
        updated_at = SYSUTCDATETIME()
    WHERE id = @RedemptionId;

    SELECT *
    FROM dbo.loyalty_redemptions
    WHERE id = @RedemptionId;
END
GO

