CREATE   PROCEDURE [dbo].[usp_benefit_requests_create]
    @BenefitId UNIQUEIDENTIFIER,
    @RequesterType VARCHAR(30),
    @RequesterUserId UNIQUEIDENTIFIER = NULL,                 -- legado
    @RequesterClientId UNIQUEIDENTIFIER = NULL,
    @RequesterPartnerCustomerId UNIQUEIDENTIFIER = NULL,
    @RequestedByUserId UNIQUEIDENTIFIER = NULL,
    @AccessCodeId UNIQUEIDENTIFIER = NULL,
    @PetSourceType VARCHAR(30) = NULL,
    @RequesterClientPetId UNIQUEIDENTIFIER = NULL,
    @RequesterPartnerCustomerPetId UNIQUEIDENTIFIER = NULL,
    @ScheduledFor DATETIME2(7) = NULL,
    @ExpiresAt DATETIME2(7) = NULL,
    @ReviewRequired BIT = 0
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
        RAISERROR('Benefício não encontrado.', 16, 1);
        RETURN;
    END

    IF @BenefitStatus NOT IN ('active', 'approved')
    BEGIN
        RAISERROR('Benefício não está disponível para solicitação.', 16, 1);
        RETURN;
    END

    IF @RequesterType NOT IN ('client', 'partner_customer')
    BEGIN
        RAISERROR('RequesterType inválido.', 16, 1);
        RETURN;
    END

    IF @RequiresAccessCode = 1 AND @AccessCodeId IS NULL
    BEGIN
        RAISERROR('Este benefício exige código de acesso.', 16, 1);
        RETURN;
    END

    IF @RequesterType = 'client' AND @RequesterClientId IS NULL AND @RequesterUserId IS NULL
    BEGIN
        RAISERROR('Solicitação de cliente exige RequesterClientId ou RequesterUserId.', 16, 1);
        RETURN;
    END

    IF @RequesterType = 'partner_customer' AND @RequesterPartnerCustomerId IS NULL
    BEGIN
        RAISERROR('Solicitação de cliente parceiro exige RequesterPartnerCustomerId.', 16, 1);
        RETURN;
    END

    IF @PetSourceType IS NOT NULL AND @PetSourceType NOT IN ('client_pet', 'partner_customer_pet')
    BEGIN
        RAISERROR('PetSourceType inválido.', 16, 1);
        RETURN;
    END

    IF @PetSourceType = 'client_pet' AND @RequesterClientPetId IS NULL
    BEGIN
        RAISERROR('PetSourceType client_pet exige RequesterClientPetId.', 16, 1);
        RETURN;
    END

    IF @PetSourceType = 'partner_customer_pet' AND @RequesterPartnerCustomerPetId IS NULL
    BEGIN
        RAISERROR('PetSourceType partner_customer_pet exige RequesterPartnerCustomerPetId.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.benefit_requests
    (
        id,
        benefit_id,
        partner_id,
        requester_user_id,
        requester_client_id,
        requester_partner_customer_id,
        requested_by_user_id,
        requester_type,
        pet_source_type,
        requester_client_pet_id,
        requester_partner_customer_pet_id,
        access_code_id,
        request_status,
        review_required,
        approval_status,
        approval_requested_at,
        requested_at,
        scheduled_for,
        expires_at,
        created_at,
        updated_at
    )
    VALUES
    (
        NEWID(),
        @BenefitId,
        @PartnerId,
        @RequesterUserId,
        @RequesterClientId,
        @RequesterPartnerCustomerId,
        @RequestedByUserId,
        @RequesterType,
        @PetSourceType,
        @RequesterClientPetId,
        @RequesterPartnerCustomerPetId,
        @AccessCodeId,
        CASE WHEN @ReviewRequired = 1 THEN 'pending_review' ELSE 'requested' END,
        @ReviewRequired,
        CASE WHEN @ReviewRequired = 1 THEN 'pending_review' ELSE NULL END,
        CASE WHEN @ReviewRequired = 1 THEN SYSUTCDATETIME() ELSE NULL END,
        SYSUTCDATETIME(),
        @ScheduledFor,
        @ExpiresAt,
        SYSUTCDATETIME(),
        SYSUTCDATETIME()
    );

    UPDATE dbo.benefit_metrics_snapshot
    SET
        requests_count = requests_count + 1,
        refreshed_at = SYSUTCDATETIME()
    WHERE benefit_id = @BenefitId;
END
GO


