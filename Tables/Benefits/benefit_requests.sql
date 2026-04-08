CREATE TABLE [dbo].[benefit_requests](
	[id] [uniqueidentifier] NOT NULL,
	[benefit_id] [uniqueidentifier] NOT NULL,
	[partner_id] [uniqueidentifier] NOT NULL,
	[requester_user_id] [uniqueidentifier] NULL,
	[requester_partner_customer_id] [uniqueidentifier] NULL,
	[requester_type] [varchar](30) NOT NULL,
	[pet_id] [uniqueidentifier] NULL,
	[access_code_id] [uniqueidentifier] NULL,
	[request_status] [varchar](30) NOT NULL,
	[requested_at] [datetime2](7) NOT NULL,
	[reviewed_at] [datetime2](7) NULL,
	[reviewed_by_user_id] [uniqueidentifier] NULL,
	[review_notes] [varchar](1500) NULL,
	[scheduled_for] [datetime2](7) NULL,
	[expires_at] [datetime2](7) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[requester_client_id] [uniqueidentifier] NULL,
	[requester_client_pet_id] [uniqueidentifier] NULL,
	[requester_partner_customer_pet_id] [uniqueidentifier] NULL,
	[requested_by_user_id] [uniqueidentifier] NULL,
	[pet_source_type] [varchar](30) NULL,
	[review_required] [bit] NOT NULL,
	[approval_status] [varchar](30) NULL,
	[approval_requested_at] [datetime2](7) NULL,
	[approval_decided_at] [datetime2](7) NULL,
	[approval_decided_by_user_id] [uniqueidentifier] NULL,
	[approval_reason] [varchar](1500) NULL,
 CONSTRAINT [PK_benefit_requests] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[benefit_requests] ADD  CONSTRAINT [DF_benefit_requests_review_required]  DEFAULT ((0)) FOR [review_required]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [FK_benefit_requests_access_codes] FOREIGN KEY([access_code_id])
REFERENCES [dbo].[partner_access_codes] ([id])
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [FK_benefit_requests_access_codes]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [FK_benefit_requests_benefits] FOREIGN KEY([benefit_id])
REFERENCES [dbo].[benefits] ([id])
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [FK_benefit_requests_benefits]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [FK_benefit_requests_client_pets] FOREIGN KEY([requester_client_pet_id])
REFERENCES [dbo].[client_pets] ([id])
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [FK_benefit_requests_client_pets]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [FK_benefit_requests_clients] FOREIGN KEY([requester_client_id])
REFERENCES [dbo].[clients] ([id])
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [FK_benefit_requests_clients]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [FK_benefit_requests_partner_customer_pets] FOREIGN KEY([requester_partner_customer_pet_id])
REFERENCES [dbo].[partner_customer_pets] ([id])
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [FK_benefit_requests_partner_customer_pets]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [FK_benefit_requests_partner_customers] FOREIGN KEY([requester_partner_customer_id])
REFERENCES [dbo].[partner_customers] ([id])
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [FK_benefit_requests_partner_customers]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [FK_benefit_requests_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [FK_benefit_requests_partners]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [FK_benefit_requests_users_approval_decided] FOREIGN KEY([approval_decided_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [FK_benefit_requests_users_approval_decided]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [FK_benefit_requests_users_requested_by] FOREIGN KEY([requested_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [FK_benefit_requests_users_requested_by]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [FK_benefit_requests_users_requester] FOREIGN KEY([requester_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [FK_benefit_requests_users_requester]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [FK_benefit_requests_users_reviewed] FOREIGN KEY([reviewed_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [FK_benefit_requests_users_reviewed]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [CK_benefit_requests_approval_status] CHECK  (([approval_status] IS NULL OR ([approval_status]='expired' OR [approval_status]='cancelled' OR [approval_status]='rejected' OR [approval_status]='approved' OR [approval_status]='under_review' OR [approval_status]='pending_review')))
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [CK_benefit_requests_approval_status]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [CK_benefit_requests_pet_presence] CHECK  (([pet_source_type] IS NULL AND [requester_client_pet_id] IS NULL AND [requester_partner_customer_pet_id] IS NULL OR [pet_source_type]='client_pet' AND [requester_client_pet_id] IS NOT NULL AND [requester_partner_customer_pet_id] IS NULL OR [pet_source_type]='partner_customer_pet' AND [requester_partner_customer_pet_id] IS NOT NULL AND [requester_client_pet_id] IS NULL))
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [CK_benefit_requests_pet_presence]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [CK_benefit_requests_pet_source_type] CHECK  (([pet_source_type] IS NULL OR ([pet_source_type]='partner_customer_pet' OR [pet_source_type]='client_pet')))
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [CK_benefit_requests_pet_source_type]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [CK_benefit_requests_request_status] CHECK  (([request_status]='converted_to_usage' OR [request_status]='no_show' OR [request_status]='scheduled' OR [request_status]='expired' OR [request_status]='cancelled' OR [request_status]='declined' OR [request_status]='approved' OR [request_status]='under_review' OR [request_status]='pending_review' OR [request_status]='requested'))
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [CK_benefit_requests_request_status]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [CK_benefit_requests_requester_presence] CHECK  (([requester_type]='client' AND [requester_partner_customer_id] IS NULL AND ([requester_client_id] IS NOT NULL OR [requester_user_id] IS NOT NULL) OR [requester_type]='partner_customer' AND [requester_partner_customer_id] IS NOT NULL AND [requester_client_id] IS NULL))
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [CK_benefit_requests_requester_presence]
GO

ALTER TABLE [dbo].[benefit_requests]  WITH CHECK ADD  CONSTRAINT [CK_benefit_requests_requester_type] CHECK  (([requester_type]='partner_customer' OR [requester_type]='client'))
GO

ALTER TABLE [dbo].[benefit_requests] CHECK CONSTRAINT [CK_benefit_requests_requester_type]
GO


