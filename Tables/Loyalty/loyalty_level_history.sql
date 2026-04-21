CREATE TABLE [dbo].[loyalty_level_history](
	[id] [uniqueidentifier] NOT NULL,
	[client_id] [uniqueidentifier] NOT NULL,
	[from_level_code] [varchar](30) NULL,
	[to_level_code] [varchar](30) NOT NULL,
	[change_reason] [varchar](1500) NULL,
	[source_type] [varchar](50) NULL,
	[source_id] [uniqueidentifier] NULL,
	[changed_at] [datetime2](7) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
 CONSTRAINT [PK_loyalty_level_history] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[loyalty_level_history]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_level_history_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO
ALTER TABLE [dbo].[loyalty_level_history] CHECK CONSTRAINT [FK_loyalty_level_history_clients]
GO
ALTER TABLE [dbo].[loyalty_level_history]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_level_history_users_created_by] FOREIGN KEY([created_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[loyalty_level_history] CHECK CONSTRAINT [FK_loyalty_level_history_users_created_by]
GO
ALTER TABLE [dbo].[loyalty_level_history]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_level_history_from_level_code] CHECK  (([from_level_code] IS NULL OR ([from_level_code]='diamond' OR [from_level_code]='gold' OR [from_level_code]='silver' OR [from_level_code]='bronze')))
GO
ALTER TABLE [dbo].[loyalty_level_history] CHECK CONSTRAINT [CK_loyalty_level_history_from_level_code]
GO
ALTER TABLE [dbo].[loyalty_level_history]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_level_history_to_level_code] CHECK  (([to_level_code]='diamond' OR [to_level_code]='gold' OR [to_level_code]='silver' OR [to_level_code]='bronze'))
GO
ALTER TABLE [dbo].[loyalty_level_history] CHECK CONSTRAINT [CK_loyalty_level_history_to_level_code]
GO

