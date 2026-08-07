CREATE   PROCEDURE [dbo].[usp_benefit_requests_create]
    @BenefitId UNIQUEIDENTIFIER,
    @RequesterType VARCHAR(30),
    @RequesterUserId UNIQUEIDENTIFIER = NULL,
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

    DECLARE @BenefitRequestId UNIQUEIDENTIFIER = NEWID();
    DECLARE @PartnerId UNIQUEIDENTIFIER;
    DECLARE @BenefitStatus VARCHAR(30);
    DECLARE @RequiresAccessCode BIT;
    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    DECLARE @RequestStatus VARCHAR(30);
    DECLARE @ApprovalStatus VARCHAR(30);
    DECLARE @ApprovalRequestedAt DATETIME2(7);

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

    IF @RequesterType = 'client'
       AND @RequesterClientId IS NULL
       AND @RequesterUserId IS NULL
    BEGIN
        RAISERROR('Solicitação de cliente exige RequesterClientId ou RequesterUserId.', 16, 1);
        RETURN;
    END

    IF @RequesterType = 'partner_customer'
       AND @RequesterPartnerCustomerId IS NULL
    BEGIN
        RAISERROR('Solicitação de cliente parceiro exige RequesterPartnerCustomerId.', 16, 1);
        RETURN;
    END

    IF @PetSourceType IS NOT NULL
       AND @PetSourceType NOT IN ('client_pet', 'partner_customer_pet')
    BEGIN
        RAISERROR('PetSourceType inválido.', 16, 1);
        RETURN;
    END

    IF @PetSourceType = 'client_pet'
       AND @RequesterClientPetId IS NULL
    BEGIN
        RAISERROR('PetSourceType client_pet exige RequesterClientPetId.', 16, 1);
        RETURN;
    END

    IF @PetSourceType = 'partner_customer_pet'
       AND @RequesterPartnerCustomerPetId IS NULL
    BEGIN
        RAISERROR('PetSourceType partner_customer_pet exige RequesterPartnerCustomerPetId.', 16, 1);
        RETURN;
    END

    SET @RequestStatus =
        CASE
            WHEN @ReviewRequired = 1 THEN 'pending_review'
            ELSE 'requested'
        END;

    SET @ApprovalStatus =
        CASE
            WHEN @ReviewRequired = 1 THEN 'pending_review'
            ELSE NULL
        END;

    SET @ApprovalRequestedAt =
        CASE
            WHEN @ReviewRequired = 1 THEN @Now
            ELSE NULL
        END;

    BEGIN TRY
        BEGIN TRANSACTION;

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
            @BenefitRequestId,
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
            @RequestStatus,
            @ReviewRequired,
            @ApprovalStatus,
            @ApprovalRequestedAt,
            @Now,
            @ScheduledFor,
            @ExpiresAt,
            @Now,
            @Now
        );

        UPDATE dbo.benefit_metrics_snapshot
        SET
            requests_count = requests_count + 1,
            conversion_rate =
                CASE
                    WHEN requests_count + 1 > 0
                        THEN CAST((approved_requests_count * 100.0) / (requests_count + 1) AS DECIMAL(9,2))
                    ELSE 0
                END,
            refreshed_at = @Now
        WHERE benefit_id = @BenefitId;

        IF @@ROWCOUNT = 0
        BEGIN
            INSERT INTO dbo.benefit_metrics_snapshot
            (
                benefit_id,
                requests_count,
                approved_requests_count,
                usages_count,
                conversion_rate,
                refreshed_at
            )
            VALUES
            (
                @BenefitId,
                1,
                0,
                0,
                0,
                @Now
            );
        END

        EXEC dbo.usp_benefit_request_notification_enqueue
            @BenefitRequestId = @BenefitRequestId,
            @EventType = 'benefits.request.created',
            @ReviewPoint = NULL,
            @ReviewRecommendation = NULL,
            @EventReferenceId = @BenefitRequestId;

        COMMIT TRANSACTION;

        SELECT
            @BenefitRequestId AS benefit_request_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO

