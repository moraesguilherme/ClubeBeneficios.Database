CREATE TABLE [dbo].[customer_level_history](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_id] [uniqueidentifier] NOT NULL,
	[level_code] [varchar](30) NOT NULL,
	[calculation_reference_date] [date] NOT NULL,
	[assigned_at] [datetime2](7) NOT NULL,
	[expires_at] [datetime2](7) NULL,
	[changed_reason] [varchar](500) NULL,
	[changed_by_user_id] [uniqueidentifier] NULL,
 CONSTRAINT [PK_customer_level_history] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[customer_level_history]  WITH CHECK ADD  CONSTRAINT [FK_customer_level_history_changed_users] FOREIGN KEY([changed_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[customer_level_history] CHECK CONSTRAINT [FK_customer_level_history_changed_users]
GO

ALTER TABLE [dbo].[customer_level_history]  WITH CHECK ADD  CONSTRAINT [FK_customer_level_history_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[customer_level_history] CHECK CONSTRAINT [FK_customer_level_history_users]
GO

ALTER TABLE [dbo].[customer_level_history]  WITH CHECK ADD  CONSTRAINT [CK_customer_level_history_level_code] CHECK  (([level_code]='platinum' OR [level_code]='diamond' OR [level_code]='gold' OR [level_code]='silver' OR [level_code]='bronze'))
GO

ALTER TABLE [dbo].[customer_level_history] CHECK CONSTRAINT [CK_customer_level_history_level_code]
GO


