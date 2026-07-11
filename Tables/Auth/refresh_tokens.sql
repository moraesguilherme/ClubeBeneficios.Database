CREATE TABLE [dbo].[refresh_tokens](
	[id] [uniqueidentifier] NOT NULL,
	[session_id] [uniqueidentifier] NOT NULL,
	[user_id] [uniqueidentifier] NULL,
	[partner_customer_id] [uniqueidentifier] NULL,
	[token] [varchar](500) NOT NULL,
	[expires_at] [datetime2](7) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[revoked_at] [datetime2](7) NULL,
	[replaced_by_token] [varchar](500) NULL,
	[created_by_ip] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_refresh_tokens_token] UNIQUE NONCLUSTERED 
(
	[token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[refresh_tokens]  WITH CHECK ADD  CONSTRAINT [FK_refresh_tokens_partner_customers] FOREIGN KEY([partner_customer_id])
REFERENCES [dbo].[partner_customers] ([id])
GO
ALTER TABLE [dbo].[refresh_tokens] CHECK CONSTRAINT [FK_refresh_tokens_partner_customers]
GO
ALTER TABLE [dbo].[refresh_tokens]  WITH CHECK ADD  CONSTRAINT [FK_refresh_tokens_sessions] FOREIGN KEY([session_id])
REFERENCES [dbo].[sessions] ([id])
GO
ALTER TABLE [dbo].[refresh_tokens] CHECK CONSTRAINT [FK_refresh_tokens_sessions]
GO
ALTER TABLE [dbo].[refresh_tokens]  WITH CHECK ADD  CONSTRAINT [FK_refresh_tokens_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[refresh_tokens] CHECK CONSTRAINT [FK_refresh_tokens_users]
GO
ALTER TABLE [dbo].[refresh_tokens]  WITH CHECK ADD  CONSTRAINT [CK_refresh_tokens_actor] CHECK  (((case when [user_id] IS NOT NULL then (1) else (0) end+case when [partner_customer_id] IS NOT NULL then (1) else (0) end)=(1)))
GO
ALTER TABLE [dbo].[refresh_tokens] CHECK CONSTRAINT [CK_refresh_tokens_actor]
GO

