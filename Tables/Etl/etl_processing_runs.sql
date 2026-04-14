CREATE TABLE [dbo].[etl_processing_runs](
	[id] [uniqueidentifier] NOT NULL,
	[batch_id] [uniqueidentifier] NULL,
	[run_type] [varchar](50) NOT NULL,
	[status] [varchar](30) NOT NULL,
	[started_at] [datetime2](7) NOT NULL,
	[finished_at] [datetime2](7) NULL,
	[processed_items] [int] NOT NULL,
	[success_items] [int] NOT NULL,
	[error_items] [int] NOT NULL,
	[log_summary] [varchar](2000) NULL,
 CONSTRAINT [PK_etl_processing_runs] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[etl_processing_runs] ADD  CONSTRAINT [DF_etl_processing_runs_processed_items]  DEFAULT ((0)) FOR [processed_items]
GO

ALTER TABLE [dbo].[etl_processing_runs] ADD  CONSTRAINT [DF_etl_processing_runs_success_items]  DEFAULT ((0)) FOR [success_items]
GO

ALTER TABLE [dbo].[etl_processing_runs] ADD  CONSTRAINT [DF_etl_processing_runs_error_items]  DEFAULT ((0)) FOR [error_items]
GO

ALTER TABLE [dbo].[etl_processing_runs]  WITH CHECK ADD  CONSTRAINT [FK_etl_processing_runs_batches] FOREIGN KEY([batch_id])
REFERENCES [dbo].[etl_import_batches] ([id])
GO

ALTER TABLE [dbo].[etl_processing_runs] CHECK CONSTRAINT [FK_etl_processing_runs_batches]
GO

ALTER TABLE [dbo].[etl_processing_runs]  WITH CHECK ADD  CONSTRAINT [CK_etl_processing_runs_run_type] CHECK  (([run_type]='expiration' OR [run_type]='loyalty_projection' OR [run_type]='event_generation' OR [run_type]='match' OR [run_type]='parse' OR [run_type]='import'))
GO

ALTER TABLE [dbo].[etl_processing_runs] CHECK CONSTRAINT [CK_etl_processing_runs_run_type]
GO

ALTER TABLE [dbo].[etl_processing_runs]  WITH CHECK ADD  CONSTRAINT [CK_etl_processing_runs_status] CHECK  (([status]='cancelled' OR [status]='failed' OR [status]='processed_with_errors' OR [status]='processed' OR [status]='processing' OR [status]='pending'))
GO

ALTER TABLE [dbo].[etl_processing_runs] CHECK CONSTRAINT [CK_etl_processing_runs_status]
GO


