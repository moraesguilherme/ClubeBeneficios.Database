CREATE TABLE [dbo].[benefit_usage_confirmations](
	[id] [uniqueidentifier] NOT NULL,
	[benefit_request_id] [uniqueidentifier] NOT NULL,
	[benefit_usage_id] [uniqueidentifier] NULL,
	[benefit_id] [uniqueidentifier] NOT NULL,
	[partner_id] [uniqueidentifier] NOT NULL,
	[confirmation_type] [varchar](30) NOT NULL,
	[confirmation_status] [varchar](30) NOT NULL,
	[recipient_email] [varchar](320) NOT NULL,
	[recipient_name] [varchar](180) NULL,
	[token_hash] [varchar](300) NOT NULL,
	[expires_at] [datetime2](7) NOT NULL,
	[confirmed_at] [datetime2](7) NULL,
	[rejected_at] [datetime2](7) NULL,
	[notification_id] [uniqueidentifier] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefit_usage_confirmations] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[benefit_usage_confirmations] ADD  CONSTRAINT [DF_benefit_usage_confirmations_id]  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[benefit_usage_confirmations] ADD  CONSTRAINT [DF_benefit_usage_confirmations_status]  DEFAULT ('pending') FOR [confirmation_status]
GO
ALTER TABLE [dbo].[benefit_usage_confirmations] ADD  CONSTRAINT [DF_benefit_usage_confirmations_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[benefit_usage_confirmations] ADD  CONSTRAINT [DF_benefit_usage_confirmations_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[benefit_usage_confirmations]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usage_confirmations_benefits] FOREIGN KEY([benefit_id])
REFERENCES [dbo].[benefits] ([id])
GO
ALTER TABLE [dbo].[benefit_usage_confirmations] CHECK CONSTRAINT [FK_benefit_usage_confirmations_benefits]
GO
ALTER TABLE [dbo].[benefit_usage_confirmations]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usage_confirmations_notifications] FOREIGN KEY([notification_id])
REFERENCES [dbo].[notification_outbox] ([id])
GO
ALTER TABLE [dbo].[benefit_usage_confirmations] CHECK CONSTRAINT [FK_benefit_usage_confirmations_notifications]
GO
ALTER TABLE [dbo].[benefit_usage_confirmations]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usage_confirmations_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO
ALTER TABLE [dbo].[benefit_usage_confirmations] CHECK CONSTRAINT [FK_benefit_usage_confirmations_partners]
GO
ALTER TABLE [dbo].[benefit_usage_confirmations]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usage_confirmations_requests] FOREIGN KEY([benefit_request_id])
REFERENCES [dbo].[benefit_requests] ([id])
GO
ALTER TABLE [dbo].[benefit_usage_confirmations] CHECK CONSTRAINT [FK_benefit_usage_confirmations_requests]
GO
ALTER TABLE [dbo].[benefit_usage_confirmations]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usage_confirmations_usages] FOREIGN KEY([benefit_usage_id])
REFERENCES [dbo].[benefit_usages] ([id])
GO
ALTER TABLE [dbo].[benefit_usage_confirmations] CHECK CONSTRAINT [FK_benefit_usage_confirmations_usages]
GO
ALTER TABLE [dbo].[benefit_usage_confirmations]  WITH CHECK ADD  CONSTRAINT [CK_benefit_usage_confirmations_status] CHECK  (([confirmation_status]='cancelled' OR [confirmation_status]='expired' OR [confirmation_status]='rejected' OR [confirmation_status]='confirmed' OR [confirmation_status]='pending'))
GO
ALTER TABLE [dbo].[benefit_usage_confirmations] CHECK CONSTRAINT [CK_benefit_usage_confirmations_status]
GO
ALTER TABLE [dbo].[benefit_usage_confirmations]  WITH CHECK ADD  CONSTRAINT [CK_benefit_usage_confirmations_type] CHECK  (([confirmation_type]='partner' OR [confirmation_type]='client'))
GO
ALTER TABLE [dbo].[benefit_usage_confirmations] CHECK CONSTRAINT [CK_benefit_usage_confirmations_type]
GO

