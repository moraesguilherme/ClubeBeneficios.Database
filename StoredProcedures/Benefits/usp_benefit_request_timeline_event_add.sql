CREATE PROCEDURE [dbo].[usp_benefit_request_timeline_event_add]
    @BenefitRequestId UNIQUEIDENTIFIER,
    @EventType VARCHAR(50),
    @EventStatus VARCHAR(30) = NULL,
    @EventPoint VARCHAR(200) = NULL,
    @EventDescription VARCHAR(1500) = NULL,
    @ActorUserId UNIQUEIDENTIFIER = NULL,
    @OccurredAt DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @OccurredAt IS NULL
        SET @OccurredAt = SYSUTCDATETIME();

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.benefit_requests
        WHERE id = @BenefitRequestId
    )
    BEGIN
        RAISERROR('Solicitação de benefício não encontrada para registro de histórico.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.benefit_request_timeline_events
    (
        benefit_request_id,
        event_type,
        event_status,
        event_point,
        event_description,
        actor_user_id,
        occurred_at,
        created_at
    )
    VALUES
    (
        @BenefitRequestId,
        @EventType,
        @EventStatus,
        @EventPoint,
        @EventDescription,
        @ActorUserId,
        @OccurredAt,
        SYSUTCDATETIME()
    );

    SELECT SCOPE_IDENTITY();
END
GO

