CREATE TABLE [dbo].[etl_import_batches](
	[id] [uniqueidentifier] NOT NULL,
	[source_name] [varchar](100) NOT NULL,
	[source_type] [varchar](50) NOT NULL,
	[file_name] [varchar](255) NULL,
	[file_hash] [varchar](128) NULL,
	[status] [varchar](30) NOT NULL,
	[total_rows] [int] NOT NULL,
	[processed_rows] [int] NOT NULL,
	[success_rows] [int] NOT NULL,
	[error_rows] [int] NOT NULL,
	[started_at] [datetime2](7) NOT NULL,
	[finished_at] [datetime2](7) NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
	[notes] [varchar](1500) NULL,
 CONSTRAINT [PK_etl_import_batches] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[etl_import_batches] ADD  CONSTRAINT [DF_etl_import_batches_total_rows]  DEFAULT ((0)) FOR [total_rows]
GO

ALTER TABLE [dbo].[etl_import_batches] ADD  CONSTRAINT [DF_etl_import_batches_processed_rows]  DEFAULT ((0)) FOR [processed_rows]
GO

ALTER TABLE [dbo].[etl_import_batches] ADD  CONSTRAINT [DF_etl_import_batches_success_rows]  DEFAULT ((0)) FOR [success_rows]
GO

ALTER TABLE [dbo].[etl_import_batches] ADD  CONSTRAINT [DF_etl_import_batches_error_rows]  DEFAULT ((0)) FOR [error_rows]
GO

ALTER TABLE [dbo].[etl_import_batches]  WITH CHECK ADD  CONSTRAINT [FK_etl_import_batches_users_created_by] FOREIGN KEY([created_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[etl_import_batches] CHECK CONSTRAINT [FK_etl_import_batches_users_created_by]
GO

ALTER TABLE [dbo].[etl_import_batches]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_batches_source_type] CHECK  (([source_type]='api' OR [source_type]='manual_upload' OR [source_type]='watched_folder' OR [source_type]='spreadsheet'))
GO

ALTER TABLE [dbo].[etl_import_batches] CHECK CONSTRAINT [CK_etl_import_batches_source_type]
GO

ALTER TABLE [dbo].[etl_import_batches]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_batches_status] CHECK  (([status]='cancelled' OR [status]='failed' OR [status]='processed_with_errors' OR [status]='processed' OR [status]='processing' OR [status]='pending'))
GO

ALTER TABLE [dbo].[etl_import_batches] CHECK CONSTRAINT [CK_etl_import_batches_status]
GO


