CREATE TABLE [dbo].[access_logs](
	[id] [uniqueidentifier] NOT NULL,
	[user_id] [uniqueidentifier] NULL,
	[partner_customer_id] [uniqueidentifier] NULL,
	[partner_id] [uniqueidentifier] NULL,
	[action] [varchar](100) NOT NULL,
	[resource] [varchar](100) NULL,
	[ip_address] [varchar](100) NULL,
	[user_agent] [varchar](500) NULL,
	[success] [bit] NOT NULL,
	[details] [varchar](1000) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[session_id] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[access_logs]  WITH CHECK ADD  CONSTRAINT [FK_access_logs_partner_customers] FOREIGN KEY([partner_customer_id])
REFERENCES [dbo].[partner_customers] ([id])
GO
ALTER TABLE [dbo].[access_logs] CHECK CONSTRAINT [FK_access_logs_partner_customers]
GO
ALTER TABLE [dbo].[access_logs]  WITH CHECK ADD  CONSTRAINT [FK_access_logs_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO
ALTER TABLE [dbo].[access_logs] CHECK CONSTRAINT [FK_access_logs_partners]
GO
ALTER TABLE [dbo].[access_logs]  WITH CHECK ADD  CONSTRAINT [FK_access_logs_sessions] FOREIGN KEY([session_id])
REFERENCES [dbo].[sessions] ([id])
GO
ALTER TABLE [dbo].[access_logs] CHECK CONSTRAINT [FK_access_logs_sessions]
GO
ALTER TABLE [dbo].[access_logs]  WITH CHECK ADD  CONSTRAINT [FK_access_logs_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[access_logs] CHECK CONSTRAINT [FK_access_logs_users]
GO

