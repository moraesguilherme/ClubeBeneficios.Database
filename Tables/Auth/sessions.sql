CREATE TABLE [dbo].[sessions](
	[id] [uniqueidentifier] NOT NULL,
	[user_id] [uniqueidentifier] NULL,
	[partner_customer_id] [uniqueidentifier] NULL,
	[access_token_jti] [varchar](100) NOT NULL,
	[ip_address] [varchar](100) NULL,
	[user_agent] [varchar](500) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[expires_at] [datetime2](7) NOT NULL,
	[revoked_at] [datetime2](7) NULL,
	[is_valid] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_sessions_access_token_jti] UNIQUE NONCLUSTERED 
(
	[access_token_jti] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sessions] ADD  CONSTRAINT [DF_sessions_is_valid]  DEFAULT ((1)) FOR [is_valid]
GO
ALTER TABLE [dbo].[sessions]  WITH CHECK ADD  CONSTRAINT [FK_sessions_partner_customers] FOREIGN KEY([partner_customer_id])
REFERENCES [dbo].[partner_customers] ([id])
GO
ALTER TABLE [dbo].[sessions] CHECK CONSTRAINT [FK_sessions_partner_customers]
GO
ALTER TABLE [dbo].[sessions]  WITH CHECK ADD  CONSTRAINT [FK_sessions_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[sessions] CHECK CONSTRAINT [FK_sessions_users]
GO
ALTER TABLE [dbo].[sessions]  WITH CHECK ADD  CONSTRAINT [CK_sessions_actor] CHECK  (((case when [user_id] IS NOT NULL then (1) else (0) end+case when [partner_customer_id] IS NOT NULL then (1) else (0) end)=(1)))
GO
ALTER TABLE [dbo].[sessions] CHECK CONSTRAINT [CK_sessions_actor]
GO

