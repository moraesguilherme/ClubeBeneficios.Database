CREATE TABLE [dbo].[users](
	[id] [uniqueidentifier] NOT NULL,
	[partner_id] [uniqueidentifier] NULL,
	[name] [varchar](150) NOT NULL,
	[email] [varchar](150) NOT NULL,
	[password_hash] [varchar](500) NOT NULL,
	[phone] [varchar](30) NULL,
	[status] [varchar](30) NOT NULL,
	[user_type] [varchar](50) NOT NULL,
	[email_confirmed] [bit] NOT NULL,
	[last_login_at] [datetime2](7) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_users_email] UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[users] ADD  CONSTRAINT [DF_users_email_confirmed]  DEFAULT ((0)) FOR [email_confirmed]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [FK_users_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [FK_users_partners]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [CK_users_status] CHECK  (([status]='pending' OR [status]='blocked' OR [status]='inactive' OR [status]='active'))
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [CK_users_status]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [CK_users_user_type] CHECK  (([user_type]='partner_customer' OR [user_type]='client' OR [user_type]='partner' OR [user_type]='admin'))
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [CK_users_user_type]
GO

