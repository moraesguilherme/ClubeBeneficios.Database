CREATE TABLE [dbo].[etl_import_rows](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[batch_id] [uniqueidentifier] NOT NULL,
	[row_number] [int] NOT NULL,
	[external_row_key] [varchar](200) NULL,
	[raw_payload_json] [nvarchar](max) NOT NULL,
	[occurred_at] [datetime2](7) NULL,
	[competence_date] [date] NULL,
	[customer_name_raw] [varchar](200) NULL,
	[customer_document_raw] [varchar](50) NULL,
	[customer_email_raw] [varchar](200) NULL,
	[customer_phone_raw] [varchar](50) NULL,
	[pet_name_raw] [varchar](150) NULL,
	[partner_name_raw] [varchar](200) NULL,
	[service_type_raw] [varchar](100) NULL,
	[plan_name_raw] [varchar](150) NULL,
	[package_name_raw] [varchar](150) NULL,
	[lodging_type_raw] [varchar](150) NULL,
	[payment_method_raw] [varchar](100) NULL,
	[payment_method_normalized] [varchar](50) NULL,
	[gross_amount] [decimal](18, 2) NULL,
	[discount_amount] [decimal](18, 2) NULL,
	[net_amount] [decimal](18, 2) NULL,
	[quantity] [decimal](18, 4) NULL,
	[status] [varchar](30) NOT NULL,
	[parsed_at] [datetime2](7) NULL,
	[processed_at] [datetime2](7) NULL,
	[reference_year] [int] NULL,
	[reference_month] [int] NULL,
	[taxi_amount] [decimal](18, 2) NULL,
	[start_date] [date] NULL,
	[end_date] [date] NULL,
	[pet_count] [int] NULL,
	[matching_reference_json] [nvarchar](max) NULL,
	[source_sheet_name] [varchar](150) NULL,
	[source_sheet_group] [varchar](100) NULL,
	[service_type_normalized] [varchar](50) NULL,
	[payment_status_raw] [varchar](100) NULL,
	[payment_status_normalized] [varchar](50) NULL,
	[description_raw] [varchar](1000) NULL,
	[observation_raw] [varchar](1500) NULL,
	[source_file_type] [varchar](50) NULL,
	[customer_phone_normalized] [varchar](30) NULL,
	[customer_document_normalized] [varchar](30) NULL,
 CONSTRAINT [PK_etl_import_rows] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[etl_import_rows]  WITH CHECK ADD  CONSTRAINT [FK_etl_import_rows_batches] FOREIGN KEY([batch_id])
REFERENCES [dbo].[etl_import_batches] ([id])
GO

ALTER TABLE [dbo].[etl_import_rows] CHECK CONSTRAINT [FK_etl_import_rows_batches]
GO

ALTER TABLE [dbo].[etl_import_rows]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_rows_payment_method_normalized] CHECK  (([payment_method_normalized] IS NULL OR ([payment_method_normalized]='other' OR [payment_method_normalized]='boleto' OR [payment_method_normalized]='bank_transfer' OR [payment_method_normalized]='debit_card' OR [payment_method_normalized]='credit_card' OR [payment_method_normalized]='cash' OR [payment_method_normalized]='pix')))
GO

ALTER TABLE [dbo].[etl_import_rows] CHECK CONSTRAINT [CK_etl_import_rows_payment_method_normalized]
GO

ALTER TABLE [dbo].[etl_import_rows]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_rows_payment_status_normalized] CHECK  (([payment_status_normalized] IS NULL OR ([payment_status_normalized]='other' OR [payment_status_normalized]='waived' OR [payment_status_normalized]='cancelled' OR [payment_status_normalized]='overdue' OR [payment_status_normalized]='pending' OR [payment_status_normalized]='partial' OR [payment_status_normalized]='paid')))
GO

ALTER TABLE [dbo].[etl_import_rows] CHECK CONSTRAINT [CK_etl_import_rows_payment_status_normalized]
GO

ALTER TABLE [dbo].[etl_import_rows]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_rows_reference_month] CHECK  (([reference_month] IS NULL OR [reference_month]>=(1) AND [reference_month]<=(12)))
GO

ALTER TABLE [dbo].[etl_import_rows] CHECK CONSTRAINT [CK_etl_import_rows_reference_month]
GO

ALTER TABLE [dbo].[etl_import_rows]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_rows_service_type_normalized] CHECK  (([service_type_normalized] IS NULL OR ([service_type_normalized]='outro' OR [service_type_normalized]='pacote' OR [service_type_normalized]='taxi_dog' OR [service_type_normalized]='avaliacao' OR [service_type_normalized]='creche' OR [service_type_normalized]='hotel')))
GO

ALTER TABLE [dbo].[etl_import_rows] CHECK CONSTRAINT [CK_etl_import_rows_service_type_normalized]
GO

ALTER TABLE [dbo].[etl_import_rows]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_rows_source_file_type] CHECK  (([source_file_type] IS NULL OR ([source_file_type]='creche_mensal' OR [source_file_type]='hotel_agenda')))
GO

ALTER TABLE [dbo].[etl_import_rows] CHECK CONSTRAINT [CK_etl_import_rows_source_file_type]
GO

ALTER TABLE [dbo].[etl_import_rows]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_rows_status] CHECK  (([status]='error' OR [status]='ignored' OR [status]='processed' OR [status]='matched' OR [status]='parsed' OR [status]='pending'))
GO

ALTER TABLE [dbo].[etl_import_rows] CHECK CONSTRAINT [CK_etl_import_rows_status]
GO


