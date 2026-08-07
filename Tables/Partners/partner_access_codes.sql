CREATE TABLE [dbo].[partner_access_codes](
	[id] [uniqueidentifier] NOT NULL,
	[partner_id] [uniqueidentifier] NOT NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
	[code] [varchar](100) NOT NULL,
	[description] [varchar](200) NULL,
	[status] [varchar](30) NOT NULL,
	[expires_at] [datetime2](7) NULL,
	[max_uses] [int] NULL,
	[used_count] [int] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_partner_access_codes_code] UNIQUE NONCLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[partner_access_codes] ADD  CONSTRAINT [DF_partner_access_codes_used_count]  DEFAULT ((0)) FOR [used_count]
GO
ALTER TABLE [dbo].[partner_access_codes]  WITH CHECK ADD  CONSTRAINT [FK_partner_access_codes_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO
ALTER TABLE [dbo].[partner_access_codes] CHECK CONSTRAINT [FK_partner_access_codes_partners]
GO
ALTER TABLE [dbo].[partner_access_codes]  WITH CHECK ADD  CONSTRAINT [FK_partner_access_codes_users] FOREIGN KEY([created_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[partner_access_codes] CHECK CONSTRAINT [FK_partner_access_codes_users]
GO
ALTER TABLE [dbo].[partner_access_codes]  WITH CHECK ADD  CONSTRAINT [CK_partner_access_codes_max_uses] CHECK  (([max_uses] IS NULL OR [max_uses]>(0)))
GO
ALTER TABLE [dbo].[partner_access_codes] CHECK CONSTRAINT [CK_partner_access_codes_max_uses]
GO
ALTER TABLE [dbo].[partner_access_codes]  WITH CHECK ADD  CONSTRAINT [CK_partner_access_codes_status] CHECK  (([status]='blocked' OR [status]='expired' OR [status]='inactive' OR [status]='active'))
GO
ALTER TABLE [dbo].[partner_access_codes] CHECK CONSTRAINT [CK_partner_access_codes_status]
GO
ALTER TABLE [dbo].[partner_access_codes]  WITH CHECK ADD  CONSTRAINT [CK_partner_access_codes_used_count] CHECK  (([used_count]>=(0)))
GO
ALTER TABLE [dbo].[partner_access_codes] CHECK CONSTRAINT [CK_partner_access_codes_used_count]
GO

