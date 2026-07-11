CREATE TABLE [dbo].[benefit_request_documents](
	[id] [uniqueidentifier] NOT NULL,
	[benefit_request_id] [uniqueidentifier] NOT NULL,
	[document_type] [varchar](40) NOT NULL,
	[source_type] [varchar](30) NOT NULL,
	[client_document_id] [uniqueidentifier] NULL,
	[partner_customer_document_id] [uniqueidentifier] NULL,
	[file_url] [varchar](500) NULL,
	[file_name] [varchar](255) NULL,
	[submission_status] [varchar](30) NOT NULL,
	[notes] [varchar](1000) NULL,
	[reviewed_at] [datetime2](7) NULL,
	[reviewed_by_user_id] [uniqueidentifier] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefit_request_documents] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_benefit_request_documents_request_type] UNIQUE NONCLUSTERED 
(
	[benefit_request_id] ASC,
	[document_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[benefit_request_documents] ADD  CONSTRAINT [DF_benefit_request_documents_id]  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[benefit_request_documents] ADD  CONSTRAINT [DF_benefit_request_documents_source_type]  DEFAULT ('uploaded') FOR [source_type]
GO
ALTER TABLE [dbo].[benefit_request_documents] ADD  CONSTRAINT [DF_benefit_request_documents_submission_status]  DEFAULT ('submitted') FOR [submission_status]
GO
ALTER TABLE [dbo].[benefit_request_documents] ADD  CONSTRAINT [DF_benefit_request_documents_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[benefit_request_documents] ADD  CONSTRAINT [DF_benefit_request_documents_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[benefit_request_documents]  WITH CHECK ADD  CONSTRAINT [FK_benefit_request_documents_client_documents] FOREIGN KEY([client_document_id])
REFERENCES [dbo].[client_documents] ([id])
GO
ALTER TABLE [dbo].[benefit_request_documents] CHECK CONSTRAINT [FK_benefit_request_documents_client_documents]
GO
ALTER TABLE [dbo].[benefit_request_documents]  WITH CHECK ADD  CONSTRAINT [FK_benefit_request_documents_partner_customer_documents] FOREIGN KEY([partner_customer_document_id])
REFERENCES [dbo].[partner_customer_documents] ([id])
GO
ALTER TABLE [dbo].[benefit_request_documents] CHECK CONSTRAINT [FK_benefit_request_documents_partner_customer_documents]
GO
ALTER TABLE [dbo].[benefit_request_documents]  WITH CHECK ADD  CONSTRAINT [FK_benefit_request_documents_requests] FOREIGN KEY([benefit_request_id])
REFERENCES [dbo].[benefit_requests] ([id])
GO
ALTER TABLE [dbo].[benefit_request_documents] CHECK CONSTRAINT [FK_benefit_request_documents_requests]
GO
ALTER TABLE [dbo].[benefit_request_documents]  WITH CHECK ADD  CONSTRAINT [FK_benefit_request_documents_reviewed_by] FOREIGN KEY([reviewed_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[benefit_request_documents] CHECK CONSTRAINT [FK_benefit_request_documents_reviewed_by]
GO
ALTER TABLE [dbo].[benefit_request_documents]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_documents_document_type] CHECK  (([document_type]='other' OR [document_type]='anti_parasite_receipt' OR [document_type]='vaccination_card'))
GO
ALTER TABLE [dbo].[benefit_request_documents] CHECK CONSTRAINT [CK_benefit_request_documents_document_type]
GO
ALTER TABLE [dbo].[benefit_request_documents]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_documents_source_presence] CHECK  (([source_type]='uploaded' AND [file_url] IS NOT NULL AND len(ltrim(rtrim([file_url])))>(0) AND [client_document_id] IS NULL AND [partner_customer_document_id] IS NULL OR [source_type]='client_profile' AND [client_document_id] IS NOT NULL AND [partner_customer_document_id] IS NULL OR [source_type]='partner_customer_profile' AND [partner_customer_document_id] IS NOT NULL AND [client_document_id] IS NULL))
GO
ALTER TABLE [dbo].[benefit_request_documents] CHECK CONSTRAINT [CK_benefit_request_documents_source_presence]
GO
ALTER TABLE [dbo].[benefit_request_documents]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_documents_source_type] CHECK  (([source_type]='partner_customer_profile' OR [source_type]='client_profile' OR [source_type]='uploaded'))
GO
ALTER TABLE [dbo].[benefit_request_documents] CHECK CONSTRAINT [CK_benefit_request_documents_source_type]
GO
ALTER TABLE [dbo].[benefit_request_documents]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_documents_submission_status] CHECK  (([submission_status]='rejected_for_request' OR [submission_status]='changes_requested' OR [submission_status]='accepted_for_request' OR [submission_status]='from_matilha_profile' OR [submission_status]='submitted'))
GO
ALTER TABLE [dbo].[benefit_request_documents] CHECK CONSTRAINT [CK_benefit_request_documents_submission_status]
GO

