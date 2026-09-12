CREATE   PROCEDURE [dbo].[usp_partners_change_status]
    @PartnerId        UNIQUEIDENTIFIER,
    @NewStatus        VARCHAR(30),
    @Reason           VARCHAR(800) = NULL,
    @ChangedByUserId  UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldStatus VARCHAR(30);
    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    DECLARE
        @PartnerName VARCHAR(180),
        @ResponsibleName VARCHAR(180),
        @ResponsibleEmail VARCHAR(150),
        @PayloadJson VARCHAR(MAX),
        @IdempotencyKey VARCHAR(220);

    SELECT
        @OldStatus = p.status,
        @PartnerName = p.trade_name
    FROM dbo.partners p
    WHERE p.id = @PartnerId;

    IF @OldStatus IS NULL
    BEGIN
        THROW 52000, 'Parceiro não encontrado.', 1;
    END;

    UPDATE dbo.partners
       SET status = @NewStatus,
           approved_at = CASE WHEN @NewStatus = 'approved' THEN @Now ELSE approved_at END,
           rejected_at = CASE WHEN @NewStatus = 'rejected' THEN @Now ELSE rejected_at END,
           inactivated_at = CASE WHEN @NewStatus = 'inactive' THEN @Now ELSE inactivated_at END,
           approved_by_user_id = CASE WHEN @NewStatus = 'approved' THEN @ChangedByUserId ELSE approved_by_user_id END,
           rejected_by_user_id = CASE WHEN @NewStatus = 'rejected' THEN @ChangedByUserId ELSE rejected_by_user_id END,
           updated_at = @Now
     WHERE id = @PartnerId;

    INSERT INTO dbo.partner_status_history
    (
        partner_id,
        from_status,
        to_status,
        reason,
        changed_by_user_id,
        changed_at
    )
    VALUES
    (
        @PartnerId,
        @OldStatus,
        @NewStatus,
        @Reason,
        @ChangedByUserId,
        @Now
    );

    IF @NewStatus = 'rejected'
    BEGIN
        SELECT TOP 1
            @ResponsibleName = c.name,
            @ResponsibleEmail = c.email
        FROM dbo.partner_contacts c
        WHERE c.partner_id = @PartnerId
          AND c.is_active = 1
        ORDER BY
            c.is_primary DESC,
            c.created_at ASC;

        IF NULLIF(LTRIM(RTRIM(@ResponsibleEmail)), '') IS NOT NULL
        BEGIN
            SET @PayloadJson =
            (
                SELECT
                    @PartnerName AS partnerName,
                    COALESCE(NULLIF(LTRIM(RTRIM(@ResponsibleName)), ''), @PartnerName) AS responsibleName
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            );

            SET @IdempotencyKey = CONCAT(
                'partner_account_rejected:',
                CONVERT(VARCHAR(36), @PartnerId),
                ':',
                CONVERT(VARCHAR(33), @Now, 126)
            );

            EXEC dbo.usp_notification_enqueue_email
                @Module = 'partners',
                @EventType = 'partner_account_rejected',
                @AggregateType = 'partner',
                @AggregateId = @PartnerId,
                @TemplateKey = 'partner_account_rejected',
                @RecipientType = 'partner',
                @RecipientEmail = @ResponsibleEmail,
                @RecipientName = @ResponsibleName,
                @CcEmails = NULL,
                @BccEmails = NULL,
                @PayloadJson = @PayloadJson,
                @Priority = 2,
                @ScheduledAt = @Now,
                @IdempotencyKey = @IdempotencyKey;
        END;
    END;
END
GO

