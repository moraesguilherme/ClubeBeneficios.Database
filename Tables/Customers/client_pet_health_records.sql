CREATE TABLE [dbo].[client_pet_health_records](
	[id] [uniqueidentifier] NOT NULL,
	[client_pet_id] [uniqueidentifier] NOT NULL,
	[record_type] [varchar](30) NOT NULL,
	[record_name] [varchar](60) NOT NULL,
	[applied_at] [date] NULL,
	[expires_at] [date] NULL,
	[status] [varchar](30) NOT NULL,
	[document_file_url] [varchar](500) NULL,
	[verified_at] [datetime2](7) NULL,
	[verified_by_user_id] [uniqueidentifier] NULL,
	[notes] [varchar](1000) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_client_pet_health_records] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[client_pet_health_records] ADD  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[client_pet_health_records] ADD  CONSTRAINT [DF_client_pet_health_records_status]  DEFAULT ('pending') FOR [status]
GO
ALTER TABLE [dbo].[client_pet_health_records] ADD  CONSTRAINT [DF_client_pet_health_records_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[client_pet_health_records] ADD  CONSTRAINT [DF_client_pet_health_records_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[client_pet_health_records]  WITH CHECK ADD  CONSTRAINT [FK_client_pet_health_records_client_pets] FOREIGN KEY([client_pet_id])
REFERENCES [dbo].[client_pets] ([id])
GO
ALTER TABLE [dbo].[client_pet_health_records] CHECK CONSTRAINT [FK_client_pet_health_records_client_pets]
GO
ALTER TABLE [dbo].[client_pet_health_records]  WITH CHECK ADD  CONSTRAINT [CK_client_pet_health_records_dates] CHECK  (([applied_at] IS NULL OR [expires_at] IS NULL OR [expires_at]>=[applied_at]))
GO
ALTER TABLE [dbo].[client_pet_health_records] CHECK CONSTRAINT [CK_client_pet_health_records_dates]
GO
ALTER TABLE [dbo].[client_pet_health_records]  WITH CHECK ADD  CONSTRAINT [CK_client_pet_health_records_record_name] CHECK  (([record_name]='medical_clearance' OR [record_name]='flea_tick_control' OR [record_name]='deworming' OR [record_name]='kennel_cough' OR [record_name]='giardia' OR [record_name]='rabies' OR [record_name]='v10'))
GO
ALTER TABLE [dbo].[client_pet_health_records] CHECK CONSTRAINT [CK_client_pet_health_records_record_name]
GO
ALTER TABLE [dbo].[client_pet_health_records]  WITH CHECK ADD  CONSTRAINT [CK_client_pet_health_records_record_type] CHECK  (([record_type]='medical_clearance' OR [record_type]='flea_tick_control' OR [record_type]='deworming' OR [record_type]='vaccine'))
GO
ALTER TABLE [dbo].[client_pet_health_records] CHECK CONSTRAINT [CK_client_pet_health_records_record_type]
GO
ALTER TABLE [dbo].[client_pet_health_records]  WITH CHECK ADD  CONSTRAINT [CK_client_pet_health_records_status] CHECK  (([status]='rejected' OR [status]='expired' OR [status]='valid' OR [status]='pending'))
GO
ALTER TABLE [dbo].[client_pet_health_records] CHECK CONSTRAINT [CK_client_pet_health_records_status]
GO

