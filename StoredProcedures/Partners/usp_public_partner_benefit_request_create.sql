CREATE PROCEDURE [dbo].[usp_public_partner_benefit_request_create]  
    @Slug VARCHAR(140),  
    @BenefitId UNIQUEIDENTIFIER,  
  
    @CustomerName VARCHAR(150),  
    @CustomerEmail VARCHAR(150) = NULL,  
    @CustomerPhone VARCHAR(30) = NULL,  
    @CustomerDocument VARCHAR(30) = NULL,  
  
    @PetName VARCHAR(120) = NULL,  
    @PetBreed VARCHAR(100) = NULL,  
    @PetSex VARCHAR(20) = NULL,  
    @PetAgeMonths INT = NULL,  
    @PetSize VARCHAR(30) = NULL,  
    @PetIsNeutered BIT = 0,  
  
    @AcceptedTerms BIT = 0,  
    @AcceptedPrivacyPolicy BIT = 0,  
    @CustomerNotes VARCHAR(1500) = NULL  
AS  
BEGIN  
    SET NOCOUNT ON;  
    SET XACT_ABORT ON;  
  
    DECLARE
		@Now DATETIME2(7) = SYSUTCDATETIME(),
		@PartnerId UNIQUEIDENTIFIER,
		@PublicCatalogLinkId UNIQUEIDENTIFIER,
		@PartnerCustomerId UNIQUEIDENTIFIER,
		@PartnerCustomerPetId UNIQUEIDENTIFIER = NULL,
		@BenefitPartnerId UNIQUEIDENTIFIER,
		@BenefitStatus VARCHAR(30),
		@BenefitDirection VARCHAR(30),
		@BenefitTargetActorType VARCHAR(30),
		@BenefitUsageScope VARCHAR(30),
		@BenefitRecurrenceType VARCHAR(40),
		@BenefitAllowFirstUseOnly BIT = 0,
		@ExistingActiveRequestId UNIQUEIDENTIFIER,
		@ExistingUsedRequestId UNIQUEIDENTIFIER,
		@RequestId UNIQUEIDENTIFIER = NEWID(); 
  
    IF ISNULL(@AcceptedTerms, 0) = 0  
    BEGIN  
        RAISERROR('É necessário aceitar os termos para solicitar o benefício.', 16, 1);  
        RETURN;  
    END  
  
    IF ISNULL(@AcceptedPrivacyPolicy, 0) = 0  
    BEGIN  
        RAISERROR('É necessário aceitar a política de privacidade para solicitar o benefício.', 16, 1);  
        RETURN;  
    END  
  
    IF NULLIF(LTRIM(RTRIM(@CustomerName)), '') IS NULL  
       AND NULLIF(LTRIM(RTRIM(@CustomerEmail)), '') IS NULL  
       AND NULLIF(LTRIM(RTRIM(@CustomerPhone)), '') IS NULL  
    BEGIN  
        RAISERROR('Informe ao menos nome, e-mail ou telefone.', 16, 1);  
        RETURN;  
    END  
  
    SELECT TOP 1  
        @PublicCatalogLinkId = pcl.id,  
        @PartnerId = pcl.partner_id  
    FROM dbo.partner_public_catalog_links pcl  
    INNER JOIN dbo.partners p  
        ON p.id = pcl.partner_id  
    WHERE pcl.slug = @Slug  
      AND pcl.status = 'active'  
      AND p.status = 'active';  
  
    IF @PartnerId IS NULL  
    BEGIN  
        RAISERROR('Vitrine pública não encontrada ou indisponível.', 16, 1);  
        RETURN;  
    END  
  
    SELECT
		@BenefitPartnerId = b.partner_id,
		@BenefitStatus = b.status,
		@BenefitDirection = b.direction,
		@BenefitTargetActorType = b.target_actor_type,
		@BenefitUsageScope = ISNULL(b.usage_scope, 'customer'),
		@BenefitRecurrenceType = b.recurrence_type,
		@BenefitAllowFirstUseOnly = ISNULL(b.allow_first_use_only, 0)
	FROM dbo.benefits b
	WHERE b.id = @BenefitId; 
  
    IF @BenefitPartnerId IS NULL  
    BEGIN  
        RAISERROR('Benefício não encontrado.', 16, 1);  
        RETURN;  
    END  
  
    IF @BenefitPartnerId <> @PartnerId  
    BEGIN  
        RAISERROR('Benefício não pertence à vitrine informada.', 16, 1);  
        RETURN;  
    END  
  
    IF @BenefitStatus <> 'active'  
       OR @BenefitDirection <> 'matilha_to_partner'  
       OR @BenefitTargetActorType <> 'partner_customer'  
    BEGIN  
        RAISERROR('Benefício indisponível para solicitação pública.', 16, 1);  
        RETURN;  
    END  
  
    BEGIN TRY  
        BEGIN TRANSACTION;  
  
        SELECT TOP 1  
            @PartnerCustomerId = pc.id  
        FROM dbo.partner_customers pc  
        WHERE pc.partner_id = @PartnerId  
          AND pc.status <> 'archived'  
          AND  
          (  
                (  
                    NULLIF(LTRIM(RTRIM(@CustomerPhone)), '') IS NOT NULL  
                    AND pc.phone = LTRIM(RTRIM(@CustomerPhone))  
                )  
                OR  
                (  
                    NULLIF(LTRIM(RTRIM(@CustomerEmail)), '') IS NOT NULL  
                    AND pc.email = LTRIM(RTRIM(@CustomerEmail))  
                )  
                OR  
                (  
                    NULLIF(LTRIM(RTRIM(@CustomerDocument)), '') IS NOT NULL  
                    AND pc.document = LTRIM(RTRIM(@CustomerDocument))  
                )  
          )  
        ORDER BY pc.updated_at DESC;  
  
        IF @PartnerCustomerId IS NULL  
        BEGIN  
            SET @PartnerCustomerId = NEWID();  
  
      INSERT INTO dbo.partner_customers  
            (  
                id,  
                partner_id,  
                access_code_id,  
                public_catalog_link_id,  
                full_name,  
                email,  
                phone,  
                document,  
                status,  
                created_at,  
                last_access_at,  
                updated_at,  
                origin_type,  
                origin_channel,  
                registration_stage,  
                first_access_at,  
                accepted_terms_at,  
                accepted_privacy_policy_at,  
                notes_summary,  
                created_by_user_id,  
                updated_by_user_id  
            )  
            VALUES  
            (  
                @PartnerCustomerId,  
                @PartnerId,  
                NULL,  
                @PublicCatalogLinkId,  
                NULLIF(LTRIM(RTRIM(@CustomerName)), ''),  
                NULLIF(LTRIM(RTRIM(@CustomerEmail)), ''),  
                NULLIF(LTRIM(RTRIM(@CustomerPhone)), ''),  
                NULLIF(LTRIM(RTRIM(@CustomerDocument)), ''),  
                'active',  
                @Now,  
                @Now,  
                @Now,  
                'partner_qr_code',  
                'qr_code',  
                'under_review',  
                @Now,  
                @Now,  
                @Now,  
                @CustomerNotes,  
                NULL,  
                NULL  
            );  
  
            INSERT INTO dbo.partner_customer_status_history  
            (  
                id,  
                partner_customer_id,  
                old_status,  
                new_status,  
                old_registration_stage,  
                new_registration_stage,  
                reason,  
                changed_at,  
                changed_by_user_id  
            )  
            VALUES  
            (  
                NEWID(),  
                @PartnerCustomerId,  
                NULL,  
                'active',  
                NULL,  
                'under_review',  
                'Pré-cadastro realizado pela vitrine pública do parceiro.',  
                @Now,  
                NULL  
            );  
        END  
        ELSE  
        BEGIN  
            UPDATE dbo.partner_customers  
            SET  
                public_catalog_link_id = ISNULL(public_catalog_link_id, @PublicCatalogLinkId),  
                full_name = COALESCE(NULLIF(LTRIM(RTRIM(@CustomerName)), ''), full_name),  
                email = COALESCE(NULLIF(LTRIM(RTRIM(@CustomerEmail)), ''), email),  
                phone = COALESCE(NULLIF(LTRIM(RTRIM(@CustomerPhone)), ''), phone),  
                document = COALESCE(NULLIF(LTRIM(RTRIM(@CustomerDocument)), ''), document),  
                registration_stage = CASE  
                    WHEN registration_stage IN ('pre_registered', 'profile_completed', 'pet_completed')  
                        THEN 'under_review'  
                    ELSE registration_stage  
                END,  
                accepted_terms_at = COALESCE(accepted_terms_at, @Now),  
                accepted_privacy_policy_at = COALESCE(accepted_privacy_policy_at, @Now),  
                last_access_at = @Now,  
                updated_at = @Now,  
                notes_summary = COALESCE(NULLIF(LTRIM(RTRIM(@CustomerNotes)), ''), notes_summary)  
            WHERE id = @PartnerCustomerId;  
        END  
  
        IF NULLIF(LTRIM(RTRIM(@PetName)), '') IS NOT NULL
		BEGIN
			SELECT TOP 1
				@PartnerCustomerPetId = pcp.id
			FROM dbo.partner_customer_pets pcp
			WHERE pcp.partner_customer_id = @PartnerCustomerId
			  AND pcp.status = 'active'
			  AND LOWER(LTRIM(RTRIM(pcp.name))) = LOWER(LTRIM(RTRIM(@PetName)))
			ORDER BY pcp.updated_at DESC, pcp.created_at DESC;

			IF @PartnerCustomerPetId IS NULL
			BEGIN
				SET @PartnerCustomerPetId = NEWID();

				INSERT INTO dbo.partner_customer_pets
				(
					id,
					partner_customer_id,
					name,
					species,
					breed,
					sex,
					age_months,
					size,
					is_neutered,
					behavior_status,
					status,
					created_at,
					updated_at
				)
				VALUES
				(
					@PartnerCustomerPetId,
					@PartnerCustomerId,
					LTRIM(RTRIM(@PetName)),
					'dog',
					NULLIF(LTRIM(RTRIM(@PetBreed)), ''),
					NULLIF(LTRIM(RTRIM(@PetSex)), ''),
					@PetAgeMonths,
					NULLIF(LTRIM(RTRIM(@PetSize)), ''),
					ISNULL(@PetIsNeutered, 0),
					'pending_evaluation',
					'active',
					@Now,
					@Now
				);
			END
			ELSE
			BEGIN
				UPDATE dbo.partner_customer_pets
				SET
					breed = COALESCE(NULLIF(LTRIM(RTRIM(@PetBreed)), ''), breed),
					sex = COALESCE(NULLIF(LTRIM(RTRIM(@PetSex)), ''), sex),
					age_months = COALESCE(@PetAgeMonths, age_months),
					size = COALESCE(NULLIF(LTRIM(RTRIM(@PetSize)), ''), size),
					is_neutered = ISNULL(@PetIsNeutered, is_neutered),
					updated_at = @Now
				WHERE id = @PartnerCustomerPetId;
			END
		END  
  
        IF @BenefitUsageScope = 'customer_pet'
		   AND @PartnerCustomerPetId IS NULL
		BEGIN
			RAISERROR('Informe o pet para solicitar este benefício.', 16, 1);
			RETURN;
		END;
		
		SELECT TOP 1
			@ExistingActiveRequestId = br.id
		FROM dbo.benefit_requests br
		WHERE br.benefit_id = @BenefitId
		  AND br.partner_id = @PartnerId
		  AND br.requester_type = 'partner_customer'
		  AND br.requester_partner_customer_id = @PartnerCustomerId
		  AND
		  (
			  @BenefitUsageScope = 'customer'
			  OR
			  (
				  @BenefitUsageScope = 'customer_pet'
				  AND br.requester_partner_customer_pet_id = @PartnerCustomerPetId
			  )
		  )
		  AND br.request_status IN
		  (
			  'requested',
			  'pending_review',
			  'under_review',
			  'approved',
			  'scheduled'
		  )
		ORDER BY br.created_at DESC;

		IF @ExistingActiveRequestId IS NOT NULL
		BEGIN
			IF @BenefitUsageScope = 'customer_pet'
			BEGIN
				RAISERROR('Já existe uma solicitação ativa para este benefício para este pet. Aguarde a análise da Matilha ou verifique seu e-mail.', 16, 1);
				RETURN;
			END;

			RAISERROR('Já existe uma solicitação ativa para este benefício. Aguarde a análise da Matilha ou verifique seu e-mail.', 16, 1);
			RETURN;
		END;

		IF @BenefitRecurrenceType IN ('once_per_customer', 'first_use_only')
		   OR ISNULL(@BenefitAllowFirstUseOnly, 0) = 1
		BEGIN
			SET @ExistingUsedRequestId = NULL;

			SELECT TOP 1
				@ExistingUsedRequestId = br.id
			FROM dbo.benefit_requests br
			LEFT JOIN dbo.benefit_usages bu
				ON bu.benefit_request_id = br.id
			   AND bu.usage_status IN ('confirmed', 'used')
			WHERE br.benefit_id = @BenefitId
			  AND br.partner_id = @PartnerId
			  AND br.requester_type = 'partner_customer'
			  AND br.requester_partner_customer_id = @PartnerCustomerId
			  AND
			  (
				  @BenefitUsageScope = 'customer'
				  OR
				  (
					  @BenefitUsageScope = 'customer_pet'
					  AND br.requester_partner_customer_pet_id = @PartnerCustomerPetId
				  )
			  )
			  AND
			  (
				  br.request_status = 'converted_to_usage'
				  OR bu.id IS NOT NULL
			  )
			ORDER BY br.created_at DESC;

			IF @ExistingUsedRequestId IS NOT NULL
			BEGIN
				IF @BenefitUsageScope = 'customer_pet'
				BEGIN
					RAISERROR('Este benefício é permitido apenas uma vez por pet e já foi utilizado para este cão.', 16, 1);
					RETURN;
				END;

				RAISERROR('Este benefício é permitido apenas uma vez por cliente e já foi utilizado.', 16, 1);
				RETURN;
			END;
		END;
  
        INSERT INTO dbo.benefit_requests  
        (  
            id,  
            benefit_id,  
            partner_id,  
            requester_user_id,  
            requester_partner_customer_id,  
            requester_type,  
            pet_id,  
            access_code_id,  
            public_catalog_link_id,  
            request_status,  
            requested_at,  
            reviewed_at,  
            reviewed_by_user_id,  
            review_notes,  
            scheduled_for,  
            expires_at,  
            created_at,  
            updated_at,  
            requester_client_id,  
            requester_client_pet_id,  
            requester_partner_customer_pet_id,  
            requested_by_user_id,  
            pet_source_type,  
            review_required,  
            approval_status,  
            approval_requested_at,  
            approval_decided_at,  
            approval_decided_by_user_id,  
            approval_reason  
        )  
        VALUES  
        (  
            @RequestId,  
            @BenefitId,  
            @PartnerId,  
            NULL,  
            @PartnerCustomerId,  
            'partner_customer',  
            NULL,  
            NULL,  
            @PublicCatalogLinkId,  
            'pending_review',  
            @Now,  
            NULL,  
            NULL,  
            NULL,  
            NULL,  
            DATEADD(DAY, 30, @Now),  
            @Now,  
            @Now,  
            NULL,  
            NULL,  
            @PartnerCustomerPetId,  
            NULL,  
            CASE  
                WHEN @PartnerCustomerPetId IS NULL THEN NULL  
                ELSE 'partner_customer_pet'  
            END,  
            1,  
            'pending_review',  
            @Now,  
            NULL,  
            NULL,  
            NULL  
        );  
  
        INSERT INTO dbo.partner_customer_notes  
        (  
            id,  
            partner_customer_id,  
            note_type,  
            title,  
            content,  
            is_internal,  
            created_at,  
            created_by_user_id  
        )  
        VALUES  
        (  
            NEWID(),  
            @PartnerCustomerId,  
            'benefit',  
            'Solicitação de benefício pela vitrine pública',  
            CONCAT(  
                'Solicitou o benefício ',  
                CONVERT(VARCHAR(36), @BenefitId),  
                '. Observações do cliente: ',  
                COALESCE(NULLIF(LTRIM(RTRIM(@CustomerNotes)), ''), 'Não informado.')  
            ),  
            1,  
            @Now,  
            NULL  
        );  
  
        COMMIT TRANSACTION;  
  
        SELECT  
            @RequestId AS RequestId,  
            @PartnerCustomerId AS PartnerCustomerId,  
            @PartnerCustomerPetId AS PartnerCustomerPetId,  
            @BenefitId AS BenefitId,  
            @PartnerId AS PartnerId,  
            'pending_review' AS RequestStatus,  
            'pending_review' AS ApprovalStatus,  
            'Solicitação enviada para análise da Matilha.' AS Message;  
    END TRY  
    BEGIN CATCH  
        IF @@TRANCOUNT > 0  
            ROLLBACK TRANSACTION;  
  
        THROW;  
    END CATCH  
END  
GO

