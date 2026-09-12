CREATE TABLE [dbo].[client_account_invitations](
	[id] [uniqueidentifier] NOT NULL,
	[client_id] [uniqueidentifier] NOT NULL,
	[user_id] [uniqueidentifier] NULL,
	[email] [varchar](150) NOT NULL,
	[token_hash] [varchar](128) NOT NULL,
	[status] [varchar](30) NOT NULL,
	[expires_at] [datetime2](7) NOT NULL,
	[accepted_at] [datetime2](7) NULL,
	[cancelled_at] [datetime2](7) NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_client_account_invitations] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_client_account_invitations_token_hash] UNIQUE NONCLUSTERED 
(
	[token_hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[client_account_invitations] ADD  CONSTRAINT [DF_client_account_invitations_id]  DEFAULT (newid()) FOR [id]
GO
ALTER TABLE [dbo].[client_account_invitations] ADD  CONSTRAINT [DF_client_account_invitations_status]  DEFAULT ('pending') FOR [status]
GO
ALTER TABLE [dbo].[client_account_invitations] ADD  CONSTRAINT [DF_client_account_invitations_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[client_account_invitations] ADD  CONSTRAINT [DF_client_account_invitations_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[client_account_invitations]  WITH CHECK ADD  CONSTRAINT [FK_client_account_invitations_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO
ALTER TABLE [dbo].[client_account_invitations] CHECK CONSTRAINT [FK_client_account_invitations_clients]
GO
ALTER TABLE [dbo].[client_account_invitations]  WITH CHECK ADD  CONSTRAINT [FK_client_account_invitations_created_by_users] FOREIGN KEY([created_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[client_account_invitations] CHECK CONSTRAINT [FK_client_account_invitations_created_by_users]
GO
ALTER TABLE [dbo].[client_account_invitations]  WITH CHECK ADD  CONSTRAINT [FK_client_account_invitations_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[client_account_invitations] CHECK CONSTRAINT [FK_client_account_invitations_users]
GO
ALTER TABLE [dbo].[client_account_invitations]  WITH CHECK ADD  CONSTRAINT [CK_client_account_invitations_status] CHECK  (([status]='cancelled' OR [status]='expired' OR [status]='accepted' OR [status]='pending'))
GO
ALTER TABLE [dbo].[client_account_invitations] CHECK CONSTRAINT [CK_client_account_invitations_status]
GO

