CREATE PROCEDURE [dbo].[usp_etl_service_payment_fact_upsert]
    @ImportRowId                    bigint,
    @BatchId                        uniqueidentifier,
    @SourceFileType                 varchar(50),
    @SourceSheetName                varchar(150) = NULL,
    @ReferenceYear                  int = NULL,
    @ReferenceMonth                 int = NULL,
    @ServiceFamily                  varchar(30),
    @ServiceType                    varchar(50),
    @PlanName                       varchar(150) = NULL,
    @PackageName                    varchar(150) = NULL,
    @PaymentStatusRaw               varchar(100) = NULL,
    @PaymentStatusNormalized        varchar(50) = NULL,
    @PaymentMethodRaw               varchar(100) = NULL,
    @PaymentMethodNormalized        varchar(50) = NULL,
    @CustomerName                   varchar(200) = NULL,
    @CustomerDocumentRaw            varchar(50) = NULL,
    @CustomerDocumentNormalized     varchar(30) = NULL,
    @CustomerPhoneRaw               varchar(50) = NULL,
    @CustomerPhoneNormalized        varchar(30) = NULL,
    @PetNameRaw                     varchar(200) = NULL,
    @PetCount                       int = NULL,
    @GrossAmount                    decimal(18,2) = NULL,
    @DiscountAmount                 decimal(18,2) = NULL,
    @NetAmount                      decimal(18,2) = NULL,
    @TaxiAmount                     decimal(18,2) = NULL,
    @Quantity                       decimal(18,4) = NULL,
    @OccurredAt                     datetime2(7) = NULL,
    @StartDate                      date = NULL,
    @EndDate                        date = NULL,
    @CompetenceDate                 date = NULL,
    @DescriptionRaw                 varchar(1000) = NULL,
    @ObservationRaw                 varchar(1500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExistingId bigint;

    SELECT TOP (1)
        @ExistingId = id
    FROM dbo.etl_service_payment_facts
    WHERE import_row_id = @ImportRowId;

    IF @ExistingId IS NULL
    BEGIN
        INSERT INTO dbo.etl_service_payment_facts
        (
            import_row_id,
            batch_id,
            source_file_type,
            source_sheet_name,
            reference_year,
            reference_month,
            service_family,
            service_type,
            plan_name,
            package_name,
            payment_status_raw,
            payment_status_normalized,
            payment_method_raw,
            payment_method_normalized,
            customer_name,
            customer_document_raw,
            customer_document_normalized,
            customer_phone_raw,
            customer_phone_normalized,
            pet_name_raw,
            pet_count,
            gross_amount,
            discount_amount,
            net_amount,
            taxi_amount,
            quantity,
            occurred_at,
            start_date,
            end_date,
            competence_date,
            description_raw,
            observation_raw
        )
        VALUES
        (
            @ImportRowId,
            @BatchId,
            @SourceFileType,
            @SourceSheetName,
            @ReferenceYear,
            @ReferenceMonth,
            @ServiceFamily,
            @ServiceType,
            @PlanName,
            @PackageName,
            @PaymentStatusRaw,
            @PaymentStatusNormalized,
            @PaymentMethodRaw,
            @PaymentMethodNormalized,
            @CustomerName,
            @CustomerDocumentRaw,
            @CustomerDocumentNormalized,
            @CustomerPhoneRaw,
            @CustomerPhoneNormalized,
            @PetNameRaw,
            @PetCount,
            @GrossAmount,
            @DiscountAmount,
            @NetAmount,
            @TaxiAmount,
            @Quantity,
            @OccurredAt,
            @StartDate,
            @EndDate,
            @CompetenceDate,
            @DescriptionRaw,
            @ObservationRaw
        );

        SELECT CAST(SCOPE_IDENTITY() AS bigint) AS id;
        RETURN;
    END

    UPDATE dbo.etl_service_payment_facts
       SET batch_id = @BatchId,
           source_file_type = @SourceFileType,
           source_sheet_name = @SourceSheetName,
           reference_year = @ReferenceYear,
           reference_month = @ReferenceMonth,
           service_family = @ServiceFamily,
           service_type = @ServiceType,
           plan_name = @PlanName,
           package_name = @PackageName,
           payment_status_raw = @PaymentStatusRaw,
           payment_status_normalized = @PaymentStatusNormalized,
           payment_method_raw = @PaymentMethodRaw,
           payment_method_normalized = @PaymentMethodNormalized,
           customer_name = @CustomerName,
           customer_document_raw = @CustomerDocumentRaw,
           customer_document_normalized = @CustomerDocumentNormalized,
           customer_phone_raw = @CustomerPhoneRaw,
           customer_phone_normalized = @CustomerPhoneNormalized,
           pet_name_raw = @PetNameRaw,
           pet_count = @PetCount,
           gross_amount = @GrossAmount,
           discount_amount = @DiscountAmount,
           net_amount = @NetAmount,
           taxi_amount = @TaxiAmount,
           quantity = @Quantity,
           occurred_at = @OccurredAt,
           start_date = @StartDate,
           end_date = @EndDate,
           competence_date = @CompetenceDate,
           description_raw = @DescriptionRaw,
           observation_raw = @ObservationRaw,
           updated_at = SYSUTCDATETIME()
     WHERE id = @ExistingId;

    SELECT @ExistingId AS id;
END
GO


