CREATE TABLE [dbo].[partner_customer_status_history](
	[id] [uniqueidentifier] NOT NULL,
	[partner_customer_id] [uniqueidentifier] NOT NULL,
	[old_status] [varchar](30) NULL,
	[new_status] [varchar](30) NOT NULL,
	[old_registration_stage] [varchar](30) NULL,
	[new_registration_stage] [varchar](30) NULL,
	[reason] [varchar](500) NULL,
	[changed_at] [datetime2](7) NOT NULL,
	[changed_by_user_id] [uniqueidentifier] NULL,
 CONSTRAINT [PK_partner_customer_status_history] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[partner_customer_status_history] ADD  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[partner_customer_status_history] ADD  CONSTRAINT [DF_partner_customer_status_history_changed_at]  DEFAULT (sysutcdatetime()) FOR [changed_at]
GO
ALTER TABLE [dbo].[partner_customer_status_history]  WITH CHECK ADD  CONSTRAINT [FK_partner_customer_status_history_partner_customers] FOREIGN KEY([partner_customer_id])
REFERENCES [dbo].[partner_customers] ([id])
GO
ALTER TABLE [dbo].[partner_customer_status_history] CHECK CONSTRAINT [FK_partner_customer_status_history_partner_customers]
GO
ALTER TABLE [dbo].[partner_customer_status_history]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_status_history_new_registration_stage] CHECK  (([new_registration_stage] IS NULL OR ([new_registration_stage]='ineligible' OR [new_registration_stage]='eligible' OR [new_registration_stage]='under_review' OR [new_registration_stage]='documents_pending' OR [new_registration_stage]='pet_completed' OR [new_registration_stage]='profile_completed' OR [new_registration_stage]='dashboard_enabled' OR [new_registration_stage]='pre_registered')))
GO
ALTER TABLE [dbo].[partner_customer_status_history] CHECK CONSTRAINT [CK_partner_customer_status_history_new_registration_stage]
GO
ALTER TABLE [dbo].[partner_customer_status_history]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_status_history_new_status] CHECK  (([new_status]='archived' OR [new_status]='blocked' OR [new_status]='inactive' OR [new_status]='active'))
GO
ALTER TABLE [dbo].[partner_customer_status_history] CHECK CONSTRAINT [CK_partner_customer_status_history_new_status]
GO
ALTER TABLE [dbo].[partner_customer_status_history]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_status_history_old_registration_stage] CHECK  (([old_registration_stage] IS NULL OR ([old_registration_stage]='ineligible' OR [old_registration_stage]='eligible' OR [old_registration_stage]='under_review' OR [old_registration_stage]='documents_pending' OR [old_registration_stage]='pet_completed' OR [old_registration_stage]='profile_completed' OR [old_registration_stage]='dashboard_enabled' OR [old_registration_stage]='pre_registered')))
GO
ALTER TABLE [dbo].[partner_customer_status_history] CHECK CONSTRAINT [CK_partner_customer_status_history_old_registration_stage]
GO
ALTER TABLE [dbo].[partner_customer_status_history]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_status_history_old_status] CHECK  (([old_status] IS NULL OR ([old_status]='archived' OR [old_status]='blocked' OR [old_status]='inactive' OR [old_status]='active')))
GO
ALTER TABLE [dbo].[partner_customer_status_history] CHECK CONSTRAINT [CK_partner_customer_status_history_old_status]
GO

