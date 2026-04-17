CREATE PROCEDURE [dbo].[usp_etl_import_row_create]
    @BatchId uniqueidentifier,
    @RowNumber int,
    @ExternalRowKey varchar(200) = NULL,
    @RawPayloadJson nvarchar(max),

    @OccurredAt datetime2(7) = NULL,
    @CompetenceDate date = NULL,

    @CustomerNameRaw varchar(200) = NULL,
    @CustomerDocumentRaw varchar(50) = NULL,
    @CustomerEmailRaw varchar(200) = NULL,
    @CustomerPhoneRaw varchar(50) = NULL,

    @PetNameRaw varchar(150) = NULL,
    @PartnerNameRaw varchar(200) = NULL,

    @ServiceTypeRaw varchar(100) = NULL,
    @PlanNameRaw varchar(150) = NULL,
    @PackageNameRaw varchar(150) = NULL,
    @LodgingTypeRaw varchar(150) = NULL,

    @PaymentMethodRaw varchar(100) = NULL,
    @PaymentMethodNormalized varchar(50) = NULL,
    @PaymentStatusRaw varchar(100) = NULL,
    @PaymentStatusNormalized varchar(50) = NULL,

    @GrossAmount decimal(18,2) = NULL,
    @DiscountAmount decimal(18,2) = NULL,
    @NetAmount decimal(18,2) = NULL,
    @TaxiAmount decimal(18,2) = NULL,
    @Quantity decimal(18,4) = NULL,

    @StartDate date = NULL,
    @EndDate date = NULL,

    @DescriptionRaw varchar(1000) = NULL,
    @ObservationRaw varchar(1500) = NULL,

    @SourceSheetName varchar(150) = NULL,
    @SourceSheetGroup varchar(100) = NULL,
    @ReferenceYear int = NULL,
    @ReferenceMonth int = NULL,
    @SourceFileType varchar(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.etl_import_rows
    (
        batch_id,
        row_number,
        external_row_key,
        raw_payload_json,

        occurred_at,
        competence_date,

        customer_name_raw,
        customer_document_raw,
        customer_email_raw,
        customer_phone_raw,

        pet_name_raw,
        partner_name_raw,

        service_type_raw,
        plan_name_raw,
        package_name_raw,
        lodging_type_raw,

        payment_method_raw,
        payment_method_normalized,
        payment_status_raw,
        payment_status_normalized,

        gross_amount,
        discount_amount,
        net_amount,
        taxi_amount,
        quantity,

        start_date,
        end_date,

        description_raw,
        observation_raw,

        source_sheet_name,
        source_sheet_group,
        reference_year,
        reference_month,
        source_file_type,

        status,
        parsed_at,
        processed_at
    )
    VALUES
    (
        @BatchId,
        @RowNumber,
        @ExternalRowKey,
        @RawPayloadJson,

        @OccurredAt,
        @CompetenceDate,

        @CustomerNameRaw,
        @CustomerDocumentRaw,
        @CustomerEmailRaw,
        @CustomerPhoneRaw,

        @PetNameRaw,
        @PartnerNameRaw,

        @ServiceTypeRaw,
        @PlanNameRaw,
        @PackageNameRaw,
        @LodgingTypeRaw,

        @PaymentMethodRaw,
        @PaymentMethodNormalized,
        @PaymentStatusRaw,
        @PaymentStatusNormalized,

        @GrossAmount,
        @DiscountAmount,
        @NetAmount,
        @TaxiAmount,
        @Quantity,

        @StartDate,
        @EndDate,

        @DescriptionRaw,
        @ObservationRaw,

        @SourceSheetName,
        @SourceSheetGroup,
        @ReferenceYear,
        @ReferenceMonth,
        @SourceFileType,

        'pending',
        NULL,
        NULL
    );

    DECLARE @InsertedId bigint = SCOPE_IDENTITY();

    UPDATE dbo.etl_import_batches
    SET total_rows = total_rows + 1
    WHERE id = @BatchId;

    SELECT *
    FROM dbo.etl_import_rows
    WHERE id = @InsertedId;
END
GO