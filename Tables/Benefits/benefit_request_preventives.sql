CREATE TABLE [dbo].[benefit_request_preventives](
	[id] [uniqueidentifier] NOT NULL,
	[benefit_request_id] [uniqueidentifier] NOT NULL,
	[preventive_type] [varchar](30) NOT NULL,
	[source_type] [varchar](30) NOT NULL,
	[client_pet_health_record_id] [uniqueidentifier] NULL,
	[partner_customer_pet_health_record_id] [uniqueidentifier] NULL,
	[application_type] [varchar](30) NULL,
	[brand_name] [varchar](120) NULL,
	[applied_at] [date] NULL,
	[expires_at] [date] NULL,
	[submission_status] [varchar](30) NOT NULL,
	[notes] [varchar](1000) NULL,
	[reviewed_at] [datetime2](7) NULL,
	[reviewed_by_user_id] [uniqueidentifier] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefit_request_preventives] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_benefit_request_preventives_request_type] UNIQUE NONCLUSTERED 
(
	[benefit_request_id] ASC,
	[preventive_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[benefit_request_preventives] ADD  CONSTRAINT [DF_benefit_request_preventives_id]  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[benefit_request_preventives] ADD  CONSTRAINT [DF_benefit_request_preventives_source_type]  DEFAULT ('uploaded') FOR [source_type]
GO
ALTER TABLE [dbo].[benefit_request_preventives] ADD  CONSTRAINT [DF_benefit_request_preventives_submission_status]  DEFAULT ('submitted') FOR [submission_status]
GO
ALTER TABLE [dbo].[benefit_request_preventives] ADD  CONSTRAINT [DF_benefit_request_preventives_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[benefit_request_preventives] ADD  CONSTRAINT [DF_benefit_request_preventives_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[benefit_request_preventives]  WITH CHECK ADD  CONSTRAINT [FK_benefit_request_preventives_client_pet_health_records] FOREIGN KEY([client_pet_health_record_id])
REFERENCES [dbo].[client_pet_health_records] ([id])
GO
ALTER TABLE [dbo].[benefit_request_preventives] CHECK CONSTRAINT [FK_benefit_request_preventives_client_pet_health_records]
GO
ALTER TABLE [dbo].[benefit_request_preventives]  WITH CHECK ADD  CONSTRAINT [FK_benefit_request_preventives_partner_customer_pet_health_records] FOREIGN KEY([partner_customer_pet_health_record_id])
REFERENCES [dbo].[partner_customer_pet_health_records] ([id])
GO
ALTER TABLE [dbo].[benefit_request_preventives] CHECK CONSTRAINT [FK_benefit_request_preventives_partner_customer_pet_health_records]
GO
ALTER TABLE [dbo].[benefit_request_preventives]  WITH CHECK ADD  CONSTRAINT [FK_benefit_request_preventives_requests] FOREIGN KEY([benefit_request_id])
REFERENCES [dbo].[benefit_requests] ([id])
GO
ALTER TABLE [dbo].[benefit_request_preventives] CHECK CONSTRAINT [FK_benefit_request_preventives_requests]
GO
ALTER TABLE [dbo].[benefit_request_preventives]  WITH CHECK ADD  CONSTRAINT [FK_benefit_request_preventives_reviewed_by] FOREIGN KEY([reviewed_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[benefit_request_preventives] CHECK CONSTRAINT [FK_benefit_request_preventives_reviewed_by]
GO
ALTER TABLE [dbo].[benefit_request_preventives]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_preventives_application_type] CHECK  (([application_type] IS NULL OR ([application_type]='unknown' OR [application_type]='other' OR [application_type]='injectable' OR [application_type]='collar' OR [application_type]='topical' OR [application_type]='oral')))
GO
ALTER TABLE [dbo].[benefit_request_preventives] CHECK CONSTRAINT [CK_benefit_request_preventives_application_type]
GO
ALTER TABLE [dbo].[benefit_request_preventives]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_preventives_dates] CHECK  (([applied_at] IS NULL OR [expires_at] IS NULL OR [expires_at]>=[applied_at]))
GO
ALTER TABLE [dbo].[benefit_request_preventives] CHECK CONSTRAINT [CK_benefit_request_preventives_dates]
GO
ALTER TABLE [dbo].[benefit_request_preventives]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_preventives_preventive_type] CHECK  (([preventive_type]='flea_tick' OR [preventive_type]='dewormer'))
GO
ALTER TABLE [dbo].[benefit_request_preventives] CHECK CONSTRAINT [CK_benefit_request_preventives_preventive_type]
GO
ALTER TABLE [dbo].[benefit_request_preventives]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_preventives_source_presence] CHECK  (([source_type]='uploaded' AND [client_pet_health_record_id] IS NULL AND [partner_customer_pet_health_record_id] IS NULL OR [source_type]='client_profile' AND [client_pet_health_record_id] IS NOT NULL AND [partner_customer_pet_health_record_id] IS NULL OR [source_type]='partner_customer_profile' AND [partner_customer_pet_health_record_id] IS NOT NULL AND [client_pet_health_record_id] IS NULL))
GO
ALTER TABLE [dbo].[benefit_request_preventives] CHECK CONSTRAINT [CK_benefit_request_preventives_source_presence]
GO
ALTER TABLE [dbo].[benefit_request_preventives]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_preventives_source_type] CHECK  (([source_type]='partner_customer_profile' OR [source_type]='client_profile' OR [source_type]='uploaded'))
GO
ALTER TABLE [dbo].[benefit_request_preventives] CHECK CONSTRAINT [CK_benefit_request_preventives_source_type]
GO
ALTER TABLE [dbo].[benefit_request_preventives]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_preventives_submission_status] CHECK  (([submission_status]='rejected_for_request' OR [submission_status]='changes_requested' OR [submission_status]='accepted_for_request' OR [submission_status]='from_matilha_profile' OR [submission_status]='submitted'))
GO
ALTER TABLE [dbo].[benefit_request_preventives] CHECK CONSTRAINT [CK_benefit_request_preventives_submission_status]
GO

