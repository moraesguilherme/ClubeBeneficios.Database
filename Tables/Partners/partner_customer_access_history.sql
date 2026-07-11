CREATE TABLE [dbo].[partner_customer_access_history](
	[id] [uniqueidentifier] NOT NULL,
	[partner_customer_id] [uniqueidentifier] NULL,
	[partner_id] [uniqueidentifier] NOT NULL,
	[access_code_id] [uniqueidentifier] NULL,
	[anonymous_key] [varchar](100) NULL,
	[session_key] [varchar](100) NULL,
	[access_channel] [varchar](30) NOT NULL,
	[conversion_stage] [varchar](30) NOT NULL,
	[ip_address] [varchar](50) NULL,
	[user_agent] [varchar](500) NULL,
	[accessed_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_partner_customer_access_history] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[partner_customer_access_history] ADD  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[partner_customer_access_history] ADD  CONSTRAINT [DF_partner_customer_access_history_accessed_at]  DEFAULT (sysutcdatetime()) FOR [accessed_at]
GO
ALTER TABLE [dbo].[partner_customer_access_history]  WITH CHECK ADD  CONSTRAINT [FK_partner_customer_access_history_partner_access_codes] FOREIGN KEY([access_code_id])
REFERENCES [dbo].[partner_access_codes] ([id])
GO
ALTER TABLE [dbo].[partner_customer_access_history] CHECK CONSTRAINT [FK_partner_customer_access_history_partner_access_codes]
GO
ALTER TABLE [dbo].[partner_customer_access_history]  WITH CHECK ADD  CONSTRAINT [FK_partner_customer_access_history_partner_customers] FOREIGN KEY([partner_customer_id])
REFERENCES [dbo].[partner_customers] ([id])
GO
ALTER TABLE [dbo].[partner_customer_access_history] CHECK CONSTRAINT [FK_partner_customer_access_history_partner_customers]
GO
ALTER TABLE [dbo].[partner_customer_access_history]  WITH CHECK ADD  CONSTRAINT [FK_partner_customer_access_history_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO
ALTER TABLE [dbo].[partner_customer_access_history] CHECK CONSTRAINT [FK_partner_customer_access_history_partners]
GO
ALTER TABLE [dbo].[partner_customer_access_history]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_access_history_access_channel] CHECK  (([access_channel]='internal' OR [access_channel]='manual_code' OR [access_channel]='landing_page' OR [access_channel]='qr_code'))
GO
ALTER TABLE [dbo].[partner_customer_access_history] CHECK CONSTRAINT [CK_partner_customer_access_history_access_channel]
GO
ALTER TABLE [dbo].[partner_customer_access_history]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_access_history_conversion_stage] CHECK  (([conversion_stage]='benefit_requested' OR [conversion_stage]='benefit_viewed' OR [conversion_stage]='dashboard_accessed' OR [conversion_stage]='pre_registration_completed' OR [conversion_stage]='pre_registration_started' OR [conversion_stage]='code_validated' OR [conversion_stage]='landing_opened'))
GO
ALTER TABLE [dbo].[partner_customer_access_history] CHECK CONSTRAINT [CK_partner_customer_access_history_conversion_stage]
GO

