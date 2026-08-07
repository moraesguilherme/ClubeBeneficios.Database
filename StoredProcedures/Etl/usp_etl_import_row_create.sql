CREATE PROCEDURE [dbo].[usp_etl_import_row_create]
    @BatchId uniqueidentifier,
    @RowNumber int,
    @ExternalRowKey varchar(200),
    @SourceContentHash varchar(64),
    @RawPayloadJson nvarchar(max),

    @SourceFileName varchar(255) = NULL,
    @SourceSheetName varchar(150) = NULL,
    @SourceFileType varchar(50) = NULL,

    @OccurredAt datetime2(7) = NULL,
    @CompetenceDate date = NULL,

    @CustomerNameRaw varchar(200) = NULL,
    @CustomerDocumentRaw varchar(50) = NULL,
    @CustomerPhoneRaw varchar(50) = NULL,

    @RawPetNames varchar(500) = NULL,
    @PetNameRaw varchar(150) = NULL,
    @PetSplitIndex int = NULL,

    @ServiceTypeRaw varchar(100) = NULL,
    @PlanNameRaw varchar(150) = NULL,
    @PackageNameRaw varchar(150) = NULL,

    @PaymentMethodRaw varchar(100) = NULL,
    @PaymentStatusRaw varchar(100) = NULL,

    @GrossAmount decimal(18,2) = NULL,
    @TaxiAmount decimal(18,2) = NULL,
    @GroupTotalAmount decimal(18,2) = NULL,

    @StartDate date = NULL,
    @EndDate date = NULL,

    @ObservationRaw varchar(1500) = NULL,

    @ReferenceYear int = NULL,
    @ReferenceMonth int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.etl_import_rows
    (
        batch_id,
        row_number,
        external_row_key,
        source_content_hash,
        raw_payload_json,
        source_file_name,
        source_sheet_name,
        source_file_type,
        occurred_at,
        competence_date,
        customer_name_raw,
        customer_document_raw,
        customer_phone_raw,
        raw_pet_names,
        pet_name_raw,
        pet_split_index,
        service_type_raw,
        plan_name_raw,
        package_name_raw,
        payment_method_raw,
        payment_status_raw,
        gross_amount,
        taxi_amount,
        group_total_amount,
        net_amount,
        start_date,
        end_date,
        observation_raw,
        reference_year,
        reference_month,
        status,
        is_current,
        superseded_at,
        replaced_by_import_row_id
    )
    VALUES
    (
        @BatchId,
        @RowNumber,
        @ExternalRowKey,
        @SourceContentHash,
        @RawPayloadJson,
        @SourceFileName,
        @SourceSheetName,
        @SourceFileType,
        @OccurredAt,
        @CompetenceDate,
        @CustomerNameRaw,
        @CustomerDocumentRaw,
        @CustomerPhoneRaw,
        @RawPetNames,
        @PetNameRaw,
        @PetSplitIndex,
        @ServiceTypeRaw,
        @PlanNameRaw,
        @PackageNameRaw,
        @PaymentMethodRaw,
        @PaymentStatusRaw,
        @GrossAmount,
        @TaxiAmount,
        @GroupTotalAmount,
        @GroupTotalAmount,
        @StartDate,
        @EndDate,
        @ObservationRaw,
        @ReferenceYear,
        @ReferenceMonth,
        'pending',
        1,
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

