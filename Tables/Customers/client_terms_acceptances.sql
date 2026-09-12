CREATE TABLE [dbo].[client_terms_acceptances](
	[id] [uniqueidentifier] NOT NULL,
	[client_id] [uniqueidentifier] NOT NULL,
	[user_id] [uniqueidentifier] NOT NULL,
	[invitation_id] [uniqueidentifier] NULL,
	[terms_key] [varchar](80) NOT NULL,
	[terms_version] [varchar](40) NOT NULL,
	[accepted_at] [datetime2](7) NOT NULL,
	[ip_address] [varchar](45) NULL,
	[user_agent] [varchar](500) NULL,
 CONSTRAINT [PK_client_terms_acceptances] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[client_terms_acceptances] ADD  CONSTRAINT [DF_client_terms_acceptances_id]  DEFAULT (newid()) FOR [id]
GO
ALTER TABLE [dbo].[client_terms_acceptances] ADD  CONSTRAINT [DF_client_terms_acceptances_accepted_at]  DEFAULT (sysutcdatetime()) FOR [accepted_at]
GO
ALTER TABLE [dbo].[client_terms_acceptances]  WITH CHECK ADD  CONSTRAINT [FK_client_terms_acceptances_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO
ALTER TABLE [dbo].[client_terms_acceptances] CHECK CONSTRAINT [FK_client_terms_acceptances_clients]
GO
ALTER TABLE [dbo].[client_terms_acceptances]  WITH CHECK ADD  CONSTRAINT [FK_client_terms_acceptances_invitations] FOREIGN KEY([invitation_id])
REFERENCES [dbo].[client_account_invitations] ([id])
GO
ALTER TABLE [dbo].[client_terms_acceptances] CHECK CONSTRAINT [FK_client_terms_acceptances_invitations]
GO
ALTER TABLE [dbo].[client_terms_acceptances]  WITH CHECK ADD  CONSTRAINT [FK_client_terms_acceptances_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[client_terms_acceptances] CHECK CONSTRAINT [FK_client_terms_acceptances_users]
GO

