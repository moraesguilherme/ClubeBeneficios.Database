SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_benefit_requests_create
    @BenefitId UNIQUEIDENTIFIER,
    @RequesterType VARCHAR(30),
    @RequesterUserId UNIQUEIDENTIFIER = NULL,
    @RequesterPartnerCustomerId UNIQUEIDENTIFIER = NULL,
    @AccessCodeId UNIQUEIDENTIFIER = NULL,
    @PetId UNIQUEIDENTIFIER = NULL,
    @ScheduledFor DATETIME2(7) = NULL,
    @ExpiresAt DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @PartnerId UNIQUEIDENTIFIER;
    DECLARE @BenefitStatus VARCHAR(30);
    DECLARE @RequiresAccessCode BIT;

    SELECT
        @PartnerId = partner_id,
        @BenefitStatus = status,
        @RequiresAccessCode = requires_active_access_code
    FROM dbo.benefits
    WHERE id = @BenefitId;

    IF @BenefitStatus IS NULL
    BEGIN
        RAISERROR('BenefÃ­cio nÃ£o encontrado.', 16, 1);
        RETURN;
    END

    IF @BenefitStatus NOT IN ('active', 'approved')
    BEGIN
        RAISERROR('BenefÃ­cio nÃ£o estÃ¡ disponÃ­vel para solicitaÃ§Ã£o.', 16, 1);
        RETURN;
    END

    IF @RequiresAccessCode = 1 AND @AccessCodeId IS NULL
    BEGIN
        RAISERROR('Este benefÃ­cio exige cÃ³digo de acesso.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.benefit_requests
    (
        id, benefit_id, partner_id, requester_user_id, requester_partner_customer_id,
        requester_type, pet_id, access_code_id, request_status, requested_at,
        scheduled_for, expires_at, created_at, updated_at
    )
    VALUES
    (
        NEWID(), @BenefitId, @PartnerId, @RequesterUserId, @RequesterPartnerCustomerId,
        @RequesterType, @PetId, @AccessCodeId, 'requested', SYSUTCDATETIME(),
        @ScheduledFor, @ExpiresAt, SYSUTCDATETIME(), SYSUTCDATETIME()
    );

    UPDATE dbo.benefit_metrics_snapshot
    SET
        requests_count = requests_count + 1,
        refreshed_at = SYSUTCDATETIME()
    WHERE benefit_id = @BenefitId;
END
GO