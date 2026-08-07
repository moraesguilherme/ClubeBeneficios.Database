CREATE TABLE [dbo].[partners](
	[id] [uniqueidentifier] NOT NULL,
	[trade_name] [varchar](150) NOT NULL,
	[legal_name] [varchar](150) NULL,
	[document] [varchar](30) NULL,
	[email] [varchar](150) NULL,
	[phone] [varchar](30) NULL,
	[status] [varchar](30) NOT NULL,
	[logo_url] [varchar](500) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[segment] [varchar](120) NULL,
	[category] [varchar](120) NULL,
	[service_region] [varchar](180) NULL,
	[website] [varchar](250) NULL,
	[instagram] [varchar](150) NULL,
	[description] [varchar](1200) NULL,
	[level] [varchar](30) NULL,
	[indication_flow_enabled] [bit] NOT NULL,
	[access_code_flow_enabled] [bit] NOT NULL,
	[origin_type] [varchar](30) NOT NULL,
	[approved_at] [datetime2](7) NULL,
	[rejected_at] [datetime2](7) NULL,
	[inactivated_at] [datetime2](7) NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
	[approved_by_user_id] [uniqueidentifier] NULL,
	[rejected_by_user_id] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[partners] ADD  CONSTRAINT [DF_partners_indication_flow_enabled]  DEFAULT ((1)) FOR [indication_flow_enabled]
GO
ALTER TABLE [dbo].[partners] ADD  CONSTRAINT [DF_partners_access_code_flow_enabled]  DEFAULT ((1)) FOR [access_code_flow_enabled]
GO
ALTER TABLE [dbo].[partners] ADD  CONSTRAINT [DF_partners_origin_type]  DEFAULT ('admin_created') FOR [origin_type]
GO
ALTER TABLE [dbo].[partners]  WITH CHECK ADD  CONSTRAINT [FK_partners_approved_by_user] FOREIGN KEY([approved_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[partners] CHECK CONSTRAINT [FK_partners_approved_by_user]
GO
ALTER TABLE [dbo].[partners]  WITH CHECK ADD  CONSTRAINT [FK_partners_created_by_user] FOREIGN KEY([created_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[partners] CHECK CONSTRAINT [FK_partners_created_by_user]
GO
ALTER TABLE [dbo].[partners]  WITH CHECK ADD  CONSTRAINT [FK_partners_rejected_by_user] FOREIGN KEY([rejected_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[partners] CHECK CONSTRAINT [FK_partners_rejected_by_user]
GO
ALTER TABLE [dbo].[partners]  WITH CHECK ADD  CONSTRAINT [CK_partners_level] CHECK  (([level] IS NULL OR ([level]='platinum' OR [level]='diamond' OR [level]='gold' OR [level]='silver' OR [level]='bronze')))
GO
ALTER TABLE [dbo].[partners] CHECK CONSTRAINT [CK_partners_level]
GO
ALTER TABLE [dbo].[partners]  WITH CHECK ADD  CONSTRAINT [CK_partners_origin_type] CHECK  (([origin_type]='api' OR [origin_type]='migration' OR [origin_type]='self_signup' OR [origin_type]='admin_created'))
GO
ALTER TABLE [dbo].[partners] CHECK CONSTRAINT [CK_partners_origin_type]
GO
ALTER TABLE [dbo].[partners]  WITH CHECK ADD  CONSTRAINT [CK_partners_status] CHECK  (([status]='blocked' OR [status]='suspended' OR [status]='rejected' OR [status]='inactive' OR [status]='active' OR [status]='approved' OR [status]='under_review' OR [status]='pending_review'))
GO
ALTER TABLE [dbo].[partners] CHECK CONSTRAINT [CK_partners_status]
GO

