CREATE TABLE [dbo].[etl_import_rows](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[batch_id] [uniqueidentifier] NOT NULL,
	[row_number] [int] NOT NULL,
	[external_row_key] [varchar](300) NULL,
	[raw_payload_json] [nvarchar](max) NOT NULL,
	[occurred_at] [datetime2](7) NULL,
	[competence_date] [date] NULL,
	[customer_name_raw] [varchar](200) NULL,
	[customer_document_raw] [varchar](50) NULL,
	[customer_phone_raw] [varchar](50) NULL,
	[pet_name_raw] [varchar](150) NULL,
	[service_type_raw] [varchar](100) NULL,
	[plan_name_raw] [varchar](150) NULL,
	[package_name_raw] [varchar](150) NULL,
	[payment_method_raw] [varchar](100) NULL,
	[gross_amount] [decimal](18, 2) NULL,
	[net_amount] [decimal](18, 2) NULL,
	[status] [varchar](30) NOT NULL,
	[reference_year] [int] NULL,
	[reference_month] [int] NULL,
	[taxi_amount] [decimal](18, 2) NULL,
	[start_date] [date] NULL,
	[end_date] [date] NULL,
	[source_sheet_name] [varchar](150) NULL,
	[payment_status_raw] [varchar](100) NULL,
	[observation_raw] [varchar](2000) NULL,
	[source_file_type] [varchar](50) NULL,
	[source_file_name] [varchar](255) NULL,
	[source_content_hash] [varchar](64) NULL,
	[raw_pet_names] [varchar](500) NULL,
	[pet_split_index] [int] NULL,
	[group_total_amount] [decimal](18, 2) NULL,
	[imported_at] [datetime2](7) NOT NULL,
	[is_current] [bit] NOT NULL,
	[superseded_at] [datetime2](7) NULL,
	[replaced_by_import_row_id] [bigint] NULL,
 CONSTRAINT [PK_etl_import_rows] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[etl_import_rows] ADD  CONSTRAINT [DF_etl_import_rows_imported_at]  DEFAULT (sysutcdatetime()) FOR [imported_at]
GO

ALTER TABLE [dbo].[etl_import_rows] ADD  CONSTRAINT [DF_etl_import_rows_is_current]  DEFAULT ((1)) FOR [is_current]
GO

ALTER TABLE [dbo].[etl_import_rows]  WITH CHECK ADD  CONSTRAINT [FK_etl_import_rows_batches] FOREIGN KEY([batch_id])
REFERENCES [dbo].[etl_import_batches] ([id])
GO

ALTER TABLE [dbo].[etl_import_rows] CHECK CONSTRAINT [FK_etl_import_rows_batches]
GO

ALTER TABLE [dbo].[etl_import_rows]  WITH CHECK ADD  CONSTRAINT [FK_etl_import_rows_replaced_by] FOREIGN KEY([replaced_by_import_row_id])
REFERENCES [dbo].[etl_import_rows] ([id])
GO

ALTER TABLE [dbo].[etl_import_rows] CHECK CONSTRAINT [FK_etl_import_rows_replaced_by]
GO

ALTER TABLE [dbo].[etl_import_rows]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_rows_pet_split_index] CHECK  (([pet_split_index] IS NULL OR [pet_split_index]>=(1)))
GO

ALTER TABLE [dbo].[etl_import_rows] CHECK CONSTRAINT [CK_etl_import_rows_pet_split_index]
GO

ALTER TABLE [dbo].[etl_import_rows]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_rows_reference_month] CHECK  (([reference_month] IS NULL OR [reference_month]>=(1) AND [reference_month]<=(12)))
GO

ALTER TABLE [dbo].[etl_import_rows] CHECK CONSTRAINT [CK_etl_import_rows_reference_month]
GO

ALTER TABLE [dbo].[etl_import_rows]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_rows_source_file_type] CHECK  (([source_file_type] IS NULL OR [source_file_type]='unified_payments_sheet'))
GO

ALTER TABLE [dbo].[etl_import_rows] CHECK CONSTRAINT [CK_etl_import_rows_source_file_type]
GO

ALTER TABLE [dbo].[etl_import_rows]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_rows_status] CHECK  (([status]='pending' OR [status]='processed' OR [status]='ignored' OR [status]='error'))
GO

ALTER TABLE [dbo].[etl_import_rows] CHECK CONSTRAINT [CK_etl_import_rows_status]
GO


