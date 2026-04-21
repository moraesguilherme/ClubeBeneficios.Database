CREATE TABLE [dbo].[loyalty_processing_log](
	[id] [uniqueidentifier] NOT NULL,
	[import_row_id] [bigint] NOT NULL,
	[client_id] [uniqueidentifier] NULL,
	[processing_stage] [varchar](30) NOT NULL,
	[processing_status] [varchar](30) NOT NULL,
	[message] [varchar](1500) NULL,
	[loyalty_event_id] [uniqueidentifier] NULL,
	[created_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_loyalty_processing_log] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[loyalty_processing_log]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_processing_log_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO
ALTER TABLE [dbo].[loyalty_processing_log] CHECK CONSTRAINT [FK_loyalty_processing_log_clients]
GO
ALTER TABLE [dbo].[loyalty_processing_log]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_processing_log_processing_stage] CHECK  (([processing_stage]='finalization' OR [processing_stage]='score_rebuild' OR [processing_stage]='balance_rebuild' OR [processing_stage]='event_creation' OR [processing_stage]='eligibility_check'))
GO
ALTER TABLE [dbo].[loyalty_processing_log] CHECK CONSTRAINT [CK_loyalty_processing_log_processing_stage]
GO
ALTER TABLE [dbo].[loyalty_processing_log]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_processing_log_processing_status] CHECK  (([processing_status]='inconsistent' OR [processing_status]='failed' OR [processing_status]='ignored' OR [processing_status]='processed' OR [processing_status]='pending'))
GO
ALTER TABLE [dbo].[loyalty_processing_log] CHECK CONSTRAINT [CK_loyalty_processing_log_processing_status]
GO

