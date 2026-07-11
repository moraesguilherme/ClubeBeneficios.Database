CREATE   PROCEDURE [dbo].[usp_benefit_request_health_submit]
    @BenefitRequestId UNIQUEIDENTIFIER,

    /* Carteirinha */
    @IncludeVaccinationCard BIT = 0,
    @VaccinationCardSourceType VARCHAR(30) = 'uploaded',
    @VaccinationCardClientDocumentId UNIQUEIDENTIFIER = NULL,
    @VaccinationCardPartnerCustomerDocumentId UNIQUEIDENTIFIER = NULL,
    @VaccinationCardFileUrl VARCHAR(500) = NULL,
    @VaccinationCardFileName VARCHAR(255) = NULL,
    @VaccinationCardSubmissionStatus VARCHAR(30) = 'submitted',
    @VaccinationCardNotes VARCHAR(1000) = NULL,

    /* Vermífugo */
    @IncludeDewormer BIT = 0,
    @DewormerSourceType VARCHAR(30) = 'uploaded',
    @DewormerClientPetHealthRecordId UNIQUEIDENTIFIER = NULL,
    @DewormerPartnerCustomerPetHealthRecordId UNIQUEIDENTIFIER = NULL,
    @DewormerApplicationType VARCHAR(30) = NULL,
    @DewormerBrandName VARCHAR(120) = NULL,
    @DewormerAppliedAt DATE = NULL,
    @DewormerExpiresAt DATE = NULL,
    @DewormerSubmissionStatus VARCHAR(30) = 'submitted',
    @DewormerNotes VARCHAR(1000) = NULL,

    /* Antipulgas / Carrapatos */
    @IncludeFleaTick BIT = 0,
    @FleaTickSourceType VARCHAR(30) = 'uploaded',
    @FleaTickClientPetHealthRecordId UNIQUEIDENTIFIER = NULL,
    @FleaTickPartnerCustomerPetHealthRecordId UNIQUEIDENTIFIER = NULL,
    @FleaTickApplicationType VARCHAR(30) = NULL,
    @FleaTickBrandName VARCHAR(120) = NULL,
    @FleaTickAppliedAt DATE = NULL,
    @FleaTickExpiresAt DATE = NULL,
    @FleaTickSubmissionStatus VARCHAR(30) = 'submitted',
    @FleaTickNotes VARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.benefit_requests
        WHERE id = @BenefitRequestId
    )
    BEGIN
        RAISERROR('Solicitação de benefício não encontrada.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        /* =====================================================
           1. Carteirinha
           ===================================================== */

        IF @IncludeVaccinationCard = 1
        BEGIN
            IF EXISTS (
                SELECT 1
                FROM dbo.benefit_request_documents
                WHERE benefit_request_id = @BenefitRequestId
                  AND document_type = 'vaccination_card'
            )
            BEGIN
                UPDATE dbo.benefit_request_documents
                SET
                    source_type = @VaccinationCardSourceType,
                    client_document_id = @VaccinationCardClientDocumentId,
                    partner_customer_document_id = @VaccinationCardPartnerCustomerDocumentId,
                    file_url = @VaccinationCardFileUrl,
                    file_name = @VaccinationCardFileName,
                    submission_status = @VaccinationCardSubmissionStatus,
                    notes = @VaccinationCardNotes,
                    updated_at = @Now
                WHERE benefit_request_id = @BenefitRequestId
                  AND document_type = 'vaccination_card';
            END
            ELSE
            BEGIN
                INSERT INTO dbo.benefit_request_documents
                (
                    benefit_request_id,
                    document_type,
                    source_type,
                    client_document_id,
                    partner_customer_document_id,
                    file_url,
                    file_name,
                    submission_status,
                    notes,
                    created_at,
                    updated_at
                )
                VALUES
                (
                    @BenefitRequestId,
                    'vaccination_card',
                    @VaccinationCardSourceType,
                    @VaccinationCardClientDocumentId,
                    @VaccinationCardPartnerCustomerDocumentId,
                    @VaccinationCardFileUrl,
                    @VaccinationCardFileName,
                    @VaccinationCardSubmissionStatus,
                    @VaccinationCardNotes,
                    @Now,
                    @Now
                );
            END
        END

        /* =====================================================
           2. Vermífugo
           ===================================================== */

        IF @IncludeDewormer = 1
        BEGIN
            IF EXISTS (
                SELECT 1
                FROM dbo.benefit_request_preventives
                WHERE benefit_request_id = @BenefitRequestId
                  AND preventive_type = 'dewormer'
            )
            BEGIN
                UPDATE dbo.benefit_request_preventives
                SET
                    source_type = @DewormerSourceType,
                    client_pet_health_record_id = @DewormerClientPetHealthRecordId,
                    partner_customer_pet_health_record_id = @DewormerPartnerCustomerPetHealthRecordId,
                    application_type = @DewormerApplicationType,
                    brand_name = @DewormerBrandName,
                    applied_at = @DewormerAppliedAt,
                    expires_at = @DewormerExpiresAt,
                    submission_status = @DewormerSubmissionStatus,
                    notes = @DewormerNotes,
                    updated_at = @Now
                WHERE benefit_request_id = @BenefitRequestId
                  AND preventive_type = 'dewormer';
            END
            ELSE
            BEGIN
                INSERT INTO dbo.benefit_request_preventives
                (
                    benefit_request_id,
                    preventive_type,
                    source_type,
                    client_pet_health_record_id,
                    partner_customer_pet_health_record_id,
                    application_type,
                    brand_name,
                    applied_at,
                    expires_at,
                    submission_status,
                    notes,
                    created_at,
                    updated_at
                )
                VALUES
                (
                    @BenefitRequestId,
                    'dewormer',
                    @DewormerSourceType,
                    @DewormerClientPetHealthRecordId,
                    @DewormerPartnerCustomerPetHealthRecordId,
                    @DewormerApplicationType,
                    @DewormerBrandName,
                    @DewormerAppliedAt,
                    @DewormerExpiresAt,
                    @DewormerSubmissionStatus,
                    @DewormerNotes,
                    @Now,
                    @Now
                );
            END
        END

        /* =====================================================
           3. Antipulgas / Carrapatos
           ===================================================== */

        IF @IncludeFleaTick = 1
        BEGIN
            IF EXISTS (
                SELECT 1
                FROM dbo.benefit_request_preventives
                WHERE benefit_request_id = @BenefitRequestId
                  AND preventive_type = 'flea_tick'
            )
            BEGIN
                UPDATE dbo.benefit_request_preventives
                SET
                    source_type = @FleaTickSourceType,
                    client_pet_health_record_id = @FleaTickClientPetHealthRecordId,
                    partner_customer_pet_health_record_id = @FleaTickPartnerCustomerPetHealthRecordId,
                    application_type = @FleaTickApplicationType,
                    brand_name = @FleaTickBrandName,
                    applied_at = @FleaTickAppliedAt,
                    expires_at = @FleaTickExpiresAt,
                    submission_status = @FleaTickSubmissionStatus,
                    notes = @FleaTickNotes,
                    updated_at = @Now
                WHERE benefit_request_id = @BenefitRequestId
                  AND preventive_type = 'flea_tick';
            END
            ELSE
            BEGIN
                INSERT INTO dbo.benefit_request_preventives
                (
                    benefit_request_id,
                    preventive_type,
                    source_type,
                    client_pet_health_record_id,
                    partner_customer_pet_health_record_id,
                    application_type,
                    brand_name,
                    applied_at,
                    expires_at,
                    submission_status,
                    notes,
                    created_at,
                    updated_at
                )
                VALUES
                (
                    @BenefitRequestId,
                    'flea_tick',
                    @FleaTickSourceType,
                    @FleaTickClientPetHealthRecordId,
                    @FleaTickPartnerCustomerPetHealthRecordId,
                    @FleaTickApplicationType,
                    @FleaTickBrandName,
                    @FleaTickAppliedAt,
                    @FleaTickExpiresAt,
                    @FleaTickSubmissionStatus,
                    @FleaTickNotes,
                    @Now,
                    @Now
                );
            END
        END

        UPDATE dbo.benefit_requests
        SET
            updated_at = @Now
        WHERE id = @BenefitRequestId;

		EXEC dbo.usp_benefit_request_timeline_event_add
			@BenefitRequestId = @BenefitRequestId,
			@EventType = 'health_submitted',
			@EventStatus = NULL,
			@EventPoint = 'health_documents',
			@EventDescription = 'Documentos e informações de saúde enviados ou atualizados.',
			@ActorUserId = NULL,
			@OccurredAt = @Now;

        COMMIT TRANSACTION;

        SELECT
            @BenefitRequestId AS benefit_request_id;

        SELECT
            d.id,
            d.benefit_request_id,
            d.document_type,
            d.source_type,
            d.client_document_id,
            d.partner_customer_document_id,
            d.file_url,
            d.file_name,
            d.submission_status,
            d.notes,
            d.reviewed_at,
            d.reviewed_by_user_id,
            d.created_at,
            d.updated_at
        FROM dbo.benefit_request_documents d
        WHERE d.benefit_request_id = @BenefitRequestId
        ORDER BY d.document_type;

        SELECT
            p.id,
            p.benefit_request_id,
            p.preventive_type,
            p.source_type,
            p.client_pet_health_record_id,
            p.partner_customer_pet_health_record_id,
            p.application_type,
            p.brand_name,
            p.applied_at,
            p.expires_at,
            p.submission_status,
            p.notes,
            p.reviewed_at,
            p.reviewed_by_user_id,
            p.created_at,
            p.updated_at
        FROM dbo.benefit_request_preventives p
        WHERE p.benefit_request_id = @BenefitRequestId
        ORDER BY p.preventive_type;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO

