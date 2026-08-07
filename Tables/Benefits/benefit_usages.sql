CREATE TABLE [dbo].[benefit_usages](
	[id] [uniqueidentifier] NOT NULL,
	[benefit_request_id] [uniqueidentifier] NULL,
	[benefit_id] [uniqueidentifier] NOT NULL,
	[partner_id] [uniqueidentifier] NOT NULL,
	[used_by_user_id] [uniqueidentifier] NULL,
	[used_by_partner_customer_id] [uniqueidentifier] NULL,
	[used_by_type] [varchar](30) NOT NULL,
	[pet_id] [uniqueidentifier] NULL,
	[usage_status] [varchar](30) NOT NULL,
	[used_at] [datetime2](7) NOT NULL,
	[confirmed_by_partner_user_id] [uniqueidentifier] NULL,
	[confirmed_by_admin_user_id] [uniqueidentifier] NULL,
	[monetary_value] [decimal](18, 2) NULL,
	[discount_value] [decimal](18, 2) NULL,
	[snapshot_title] [varchar](180) NOT NULL,
	[snapshot_partner_name] [varchar](150) NOT NULL,
	[snapshot_rule_summary] [varchar](1000) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[used_by_client_id] [uniqueidentifier] NULL,
	[client_pet_id] [uniqueidentifier] NULL,
	[partner_customer_pet_id] [uniqueidentifier] NULL,
	[pet_source_type] [varchar](30) NULL,
	[recorded_by_user_id] [uniqueidentifier] NULL,
 CONSTRAINT [PK_benefit_usages] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usages_admin_users] FOREIGN KEY([confirmed_by_admin_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [FK_benefit_usages_admin_users]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usages_benefits] FOREIGN KEY([benefit_id])
REFERENCES [dbo].[benefits] ([id])
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [FK_benefit_usages_benefits]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usages_client_pets] FOREIGN KEY([client_pet_id])
REFERENCES [dbo].[client_pets] ([id])
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [FK_benefit_usages_client_pets]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usages_clients] FOREIGN KEY([used_by_client_id])
REFERENCES [dbo].[clients] ([id])
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [FK_benefit_usages_clients]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usages_partner_customer_pets] FOREIGN KEY([partner_customer_pet_id])
REFERENCES [dbo].[partner_customer_pets] ([id])
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [FK_benefit_usages_partner_customer_pets]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usages_partner_customers] FOREIGN KEY([used_by_partner_customer_id])
REFERENCES [dbo].[partner_customers] ([id])
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [FK_benefit_usages_partner_customers]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usages_partner_users] FOREIGN KEY([confirmed_by_partner_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [FK_benefit_usages_partner_users]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usages_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [FK_benefit_usages_partners]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usages_recorded_by_user] FOREIGN KEY([recorded_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [FK_benefit_usages_recorded_by_user]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usages_requests] FOREIGN KEY([benefit_request_id])
REFERENCES [dbo].[benefit_requests] ([id])
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [FK_benefit_usages_requests]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usages_users_used_by] FOREIGN KEY([used_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [FK_benefit_usages_users_used_by]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [CK_benefit_usages_pet_presence] CHECK  (([pet_source_type] IS NULL AND [client_pet_id] IS NULL AND [partner_customer_pet_id] IS NULL OR [pet_source_type]='client_pet' AND [client_pet_id] IS NOT NULL AND [partner_customer_pet_id] IS NULL OR [pet_source_type]='partner_customer_pet' AND [partner_customer_pet_id] IS NOT NULL AND [client_pet_id] IS NULL))
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [CK_benefit_usages_pet_presence]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [CK_benefit_usages_pet_source_type] CHECK  (([pet_source_type] IS NULL OR ([pet_source_type]='partner_customer_pet' OR [pet_source_type]='client_pet')))
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [CK_benefit_usages_pet_source_type]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [CK_benefit_usages_status] CHECK  (([usage_status]='reversed' OR [usage_status]='no_show' OR [usage_status]='cancelled' OR [usage_status]='used' OR [usage_status]='confirmed'))
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [CK_benefit_usages_status]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [CK_benefit_usages_used_by_type] CHECK  (([used_by_type]='partner_customer' OR [used_by_type]='client'))
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [CK_benefit_usages_used_by_type]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [CK_benefit_usages_user_presence] CHECK  (([used_by_type]='client' AND [used_by_partner_customer_id] IS NULL AND ([used_by_client_id] IS NOT NULL OR [used_by_user_id] IS NOT NULL) OR [used_by_type]='partner_customer' AND [used_by_partner_customer_id] IS NOT NULL AND [used_by_client_id] IS NULL))
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [CK_benefit_usages_user_presence]
GO
ALTER TABLE [dbo].[benefit_usages]  WITH CHECK ADD  CONSTRAINT [CK_benefit_usages_values] CHECK  ((([monetary_value] IS NULL OR [monetary_value]>=(0)) AND ([discount_value] IS NULL OR [discount_value]>=(0))))
GO
ALTER TABLE [dbo].[benefit_usages] CHECK CONSTRAINT [CK_benefit_usages_values]
GO

