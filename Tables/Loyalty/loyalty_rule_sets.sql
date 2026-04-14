CREATE TABLE [dbo].[loyalty_rule_sets](
	[id] [uniqueidentifier] NOT NULL,
	[name] [varchar](150) NOT NULL,
	[description] [varchar](1000) NULL,
	[status] [varchar](30) NOT NULL,
	[priority] [int] NOT NULL,
	[valid_from] [datetime2](7) NULL,
	[valid_to] [datetime2](7) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
	[updated_by_user_id] [uniqueidentifier] NULL,
 CONSTRAINT [PK_loyalty_rule_sets] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[loyalty_rule_sets] ADD  CONSTRAINT [DF_loyalty_rule_sets_priority]  DEFAULT ((0)) FOR [priority]
GO

ALTER TABLE [dbo].[loyalty_rule_sets]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_rule_sets_users_created_by] FOREIGN KEY([created_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[loyalty_rule_sets] CHECK CONSTRAINT [FK_loyalty_rule_sets_users_created_by]
GO

ALTER TABLE [dbo].[loyalty_rule_sets]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_rule_sets_users_updated_by] FOREIGN KEY([updated_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[loyalty_rule_sets] CHECK CONSTRAINT [FK_loyalty_rule_sets_users_updated_by]
GO

ALTER TABLE [dbo].[loyalty_rule_sets]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rule_sets_status] CHECK  (([status]='archived' OR [status]='inactive' OR [status]='active' OR [status]='draft'))
GO

ALTER TABLE [dbo].[loyalty_rule_sets] CHECK CONSTRAINT [CK_loyalty_rule_sets_status]
GO


