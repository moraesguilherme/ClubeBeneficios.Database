CREATE TABLE [dbo].[partner_customer_documents](
	[id] [uniqueidentifier] NOT NULL,
	[partner_customer_id] [uniqueidentifier] NOT NULL,
	[partner_customer_pet_id] [uniqueidentifier] NULL,
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
 CONSTRAINT [PK_partner_customer_documents] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[partner_customer_documents] ADD  DEFAULT (newsequentialid()) FOR [id]
GO

ALTER TABLE [dbo].[partner_customer_documents] ADD  CONSTRAINT [DF_partner_customer_documents_status]  DEFAULT ('pending') FOR [status]
GO

ALTER TABLE [dbo].[partner_customer_documents] ADD  CONSTRAINT [DF_partner_customer_documents_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO

ALTER TABLE [dbo].[partner_customer_documents] ADD  CONSTRAINT [DF_partner_customer_documents_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO

ALTER TABLE [dbo].[partner_customer_documents]  WITH CHECK ADD  CONSTRAINT [FK_partner_customer_documents_partner_customer_pets] FOREIGN KEY([partner_customer_pet_id])
REFERENCES [dbo].[partner_customer_pets] ([id])
GO

ALTER TABLE [dbo].[partner_customer_documents] CHECK CONSTRAINT [FK_partner_customer_documents_partner_customer_pets]
GO

ALTER TABLE [dbo].[partner_customer_documents]  WITH CHECK ADD  CONSTRAINT [FK_partner_customer_documents_partner_customers] FOREIGN KEY([partner_customer_id])
REFERENCES [dbo].[partner_customers] ([id])
GO

ALTER TABLE [dbo].[partner_customer_documents] CHECK CONSTRAINT [FK_partner_customer_documents_partner_customers]
GO

ALTER TABLE [dbo].[partner_customer_documents]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_documents_document_type] CHECK  (([document_type]='other' OR [document_type]='partner_indication_proof' OR [document_type]='consent_form' OR [document_type]='behavior_evaluation' OR [document_type]='anti_parasite_receipt' OR [document_type]='vaccination_card' OR [document_type]='client_document'))
GO

ALTER TABLE [dbo].[partner_customer_documents] CHECK CONSTRAINT [CK_partner_customer_documents_document_type]
GO

ALTER TABLE [dbo].[partner_customer_documents]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_documents_file_url] CHECK  ((len(ltrim(rtrim([file_url])))>(0)))
GO

ALTER TABLE [dbo].[partner_customer_documents] CHECK CONSTRAINT [CK_partner_customer_documents_file_url]
GO

ALTER TABLE [dbo].[partner_customer_documents]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_documents_status] CHECK  (([status]='rejected' OR [status]='expired' OR [status]='valid' OR [status]='pending'))
GO

ALTER TABLE [dbo].[partner_customer_documents] CHECK CONSTRAINT [CK_partner_customer_documents_status]
GO


