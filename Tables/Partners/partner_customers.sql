CREATE TABLE [dbo].[partner_customers](
	[id] [uniqueidentifier] NOT NULL,
	[partner_id] [uniqueidentifier] NOT NULL,
	[access_code_id] [uniqueidentifier] NULL,
	[full_name] [varchar](150) NULL,
	[email] [varchar](150) NULL,
	[phone] [varchar](30) NULL,
	[status] [varchar](30) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[last_access_at] [datetime2](7) NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[user_id] [uniqueidentifier] NULL,
	[document] [varchar](30) NULL,
	[birth_date] [date] NULL,
	[origin_type] [varchar](30) NOT NULL,
	[origin_channel] [varchar](30) NOT NULL,
	[registration_stage] [varchar](30) NOT NULL,
	[benefits_dashboard_unlocked_at] [datetime2](7) NULL,
	[converted_to_full_registration_at] [datetime2](7) NULL,
	[first_access_at] [datetime2](7) NULL,
	[accepted_terms_at] [datetime2](7) NULL,
	[accepted_privacy_policy_at] [datetime2](7) NULL,
	[notes_summary] [varchar](1000) NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
	[updated_by_user_id] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[partner_customers] ADD  CONSTRAINT [DF_partner_customers_status]  DEFAULT ('active') FOR [status]
GO
ALTER TABLE [dbo].[partner_customers] ADD  CONSTRAINT [DF_partner_customers_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[partner_customers] ADD  CONSTRAINT [DF_partner_customers_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[partner_customers] ADD  CONSTRAINT [DF_partner_customers_origin_type]  DEFAULT ('partner_qr_code') FOR [origin_type]
GO
ALTER TABLE [dbo].[partner_customers] ADD  CONSTRAINT [DF_partner_customers_origin_channel]  DEFAULT ('qr_code') FOR [origin_channel]
GO
ALTER TABLE [dbo].[partner_customers] ADD  CONSTRAINT [DF_partner_customers_registration_stage]  DEFAULT ('pre_registered') FOR [registration_stage]
GO
ALTER TABLE [dbo].[partner_customers]  WITH CHECK ADD  CONSTRAINT [FK_partner_customers_partner_access_codes] FOREIGN KEY([access_code_id])
REFERENCES [dbo].[partner_access_codes] ([id])
GO
ALTER TABLE [dbo].[partner_customers] CHECK CONSTRAINT [FK_partner_customers_partner_access_codes]
GO
ALTER TABLE [dbo].[partner_customers]  WITH CHECK ADD  CONSTRAINT [FK_partner_customers_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO
ALTER TABLE [dbo].[partner_customers] CHECK CONSTRAINT [FK_partner_customers_partners]
GO
ALTER TABLE [dbo].[partner_customers]  WITH CHECK ADD  CONSTRAINT [CK_partner_customers_min_identification] CHECK  (([email] IS NOT NULL OR [phone] IS NOT NULL OR [full_name] IS NOT NULL))
GO
ALTER TABLE [dbo].[partner_customers] CHECK CONSTRAINT [CK_partner_customers_min_identification]
GO
ALTER TABLE [dbo].[partner_customers]  WITH CHECK ADD  CONSTRAINT [CK_partner_customers_origin_channel] CHECK  (([origin_channel]='internal' OR [origin_channel]='manual_code' OR [origin_channel]='landing_page' OR [origin_channel]='qr_code'))
GO
ALTER TABLE [dbo].[partner_customers] CHECK CONSTRAINT [CK_partner_customers_origin_channel]
GO
ALTER TABLE [dbo].[partner_customers]  WITH CHECK ADD  CONSTRAINT [CK_partner_customers_origin_type] CHECK  (([origin_type]='imported' OR [origin_type]='manual' OR [origin_type]='partner_access_code' OR [origin_type]='partner_qr_code'))
GO
ALTER TABLE [dbo].[partner_customers] CHECK CONSTRAINT [CK_partner_customers_origin_type]
GO
ALTER TABLE [dbo].[partner_customers]  WITH CHECK ADD  CONSTRAINT [CK_partner_customers_registration_stage] CHECK  (([registration_stage]='ineligible' OR [registration_stage]='eligible' OR [registration_stage]='under_review' OR [registration_stage]='documents_pending' OR [registration_stage]='pet_completed' OR [registration_stage]='profile_completed' OR [registration_stage]='dashboard_enabled' OR [registration_stage]='pre_registered'))
GO
ALTER TABLE [dbo].[partner_customers] CHECK CONSTRAINT [CK_partner_customers_registration_stage]
GO
ALTER TABLE [dbo].[partner_customers]  WITH CHECK ADD  CONSTRAINT [CK_partner_customers_status] CHECK  (([status]='archived' OR [status]='blocked' OR [status]='inactive' OR [status]='active'))
GO
ALTER TABLE [dbo].[partner_customers] CHECK CONSTRAINT [CK_partner_customers_status]
GO

