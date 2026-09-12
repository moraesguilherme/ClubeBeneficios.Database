CREATE TABLE [dbo].[access_code_usages](
	[id] [uniqueidentifier] NOT NULL,
	[partner_access_code_id] [uniqueidentifier] NOT NULL,
	[partner_customer_id] [uniqueidentifier] NULL,
	[ip_address] [varchar](100) NULL,
	[user_agent] [varchar](500) NULL,
	[used_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[access_code_usages]  WITH CHECK ADD  CONSTRAINT [FK_access_code_usages_codes] FOREIGN KEY([partner_access_code_id])
REFERENCES [dbo].[partner_access_codes] ([id])
GO
ALTER TABLE [dbo].[access_code_usages] CHECK CONSTRAINT [FK_access_code_usages_codes]
GO
ALTER TABLE [dbo].[access_code_usages]  WITH CHECK ADD  CONSTRAINT [FK_access_code_usages_partner_customers] FOREIGN KEY([partner_customer_id])
REFERENCES [dbo].[partner_customers] ([id])
GO
ALTER TABLE [dbo].[access_code_usages] CHECK CONSTRAINT [FK_access_code_usages_partner_customers]
GO

