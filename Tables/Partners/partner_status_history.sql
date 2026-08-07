CREATE TABLE [dbo].[partner_status_history](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[partner_id] [uniqueidentifier] NOT NULL,
	[from_status] [varchar](30) NULL,
	[to_status] [varchar](30) NOT NULL,
	[reason] [varchar](800) NULL,
	[changed_by_user_id] [uniqueidentifier] NULL,
	[changed_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_partner_status_history] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[partner_status_history]  WITH CHECK ADD  CONSTRAINT [FK_partner_status_history_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO
ALTER TABLE [dbo].[partner_status_history] CHECK CONSTRAINT [FK_partner_status_history_partners]
GO
ALTER TABLE [dbo].[partner_status_history]  WITH CHECK ADD  CONSTRAINT [FK_partner_status_history_users] FOREIGN KEY([changed_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[partner_status_history] CHECK CONSTRAINT [FK_partner_status_history_users]
GO

