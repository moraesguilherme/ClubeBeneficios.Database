CREATE TABLE [dbo].[client_documents](
	[id] [uniqueidentifier] NOT NULL,
	[client_id] [uniqueidentifier] NOT NULL,
	[client_pet_id] [uniqueidentifier] NULL,
	[document_type] [varchar](40) NOT NULL,
	[file_url] [varchar](500) NOT NULL,
	[file_name] [varchar](255) NULL,
	[mime_type] [varchar](100) NULL,
	[status] [varchar](30) NOT NULL,
	[expires_at] [date] NULL,
	[verified_at] [datetime2](7) NULL,
	[verified_by_user_id] [uniqueidentifier] NULL,
	[rejection_reason] [varchar](1000) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_client_documents] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[client_documents] ADD  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[client_documents] ADD  CONSTRAINT [DF_client_documents_status]  DEFAULT ('pending') FOR [status]
GO
ALTER TABLE [dbo].[client_documents] ADD  CONSTRAINT [DF_client_documents_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[client_documents] ADD  CONSTRAINT [DF_client_documents_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[client_documents]  WITH CHECK ADD  CONSTRAINT [FK_client_documents_client_pets] FOREIGN KEY([client_pet_id])
REFERENCES [dbo].[client_pets] ([id])
GO
ALTER TABLE [dbo].[client_documents] CHECK CONSTRAINT [FK_client_documents_client_pets]
GO
ALTER TABLE [dbo].[client_documents]  WITH CHECK ADD  CONSTRAINT [FK_client_documents_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO
ALTER TABLE [dbo].[client_documents] CHECK CONSTRAINT [FK_client_documents_clients]
GO
ALTER TABLE [dbo].[client_documents]  WITH CHECK ADD  CONSTRAINT [CK_client_documents_document_type] CHECK  (([document_type]='other' OR [document_type]='consent_form' OR [document_type]='service_contract' OR [document_type]='behavior_evaluation' OR [document_type]='anti_parasite_receipt' OR [document_type]='vaccination_card' OR [document_type]='client_document'))
GO
ALTER TABLE [dbo].[client_documents] CHECK CONSTRAINT [CK_client_documents_document_type]
GO
ALTER TABLE [dbo].[client_documents]  WITH CHECK ADD  CONSTRAINT [CK_client_documents_file_url] CHECK  ((len(ltrim(rtrim([file_url])))>(0)))
GO
ALTER TABLE [dbo].[client_documents] CHECK CONSTRAINT [CK_client_documents_file_url]
GO
ALTER TABLE [dbo].[client_documents]  WITH CHECK ADD  CONSTRAINT [CK_client_documents_status] CHECK  (([status]='rejected' OR [status]='expired' OR [status]='valid' OR [status]='pending'))
GO
ALTER TABLE [dbo].[client_documents] CHECK CONSTRAINT [CK_client_documents_status]
GO

