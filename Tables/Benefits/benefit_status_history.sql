CREATE TABLE [dbo].[benefit_status_history](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[benefit_id] [uniqueidentifier] NOT NULL,
	[from_status] [varchar](30) NULL,
	[to_status] [varchar](30) NOT NULL,
	[reason] [varchar](1500) NULL,
	[changed_by_user_id] [uniqueidentifier] NULL,
	[changed_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefit_status_history] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[benefit_status_history]  WITH CHECK ADD  CONSTRAINT [FK_benefit_status_history_benefits] FOREIGN KEY([benefit_id])
REFERENCES [dbo].[benefits] ([id])
GO

ALTER TABLE [dbo].[benefit_status_history] CHECK CONSTRAINT [FK_benefit_status_history_benefits]
GO

ALTER TABLE [dbo].[benefit_status_history]  WITH CHECK ADD  CONSTRAINT [FK_benefit_status_history_users] FOREIGN KEY([changed_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[benefit_status_history] CHECK CONSTRAINT [FK_benefit_status_history_users]
GO

ALTER TABLE [dbo].[benefit_status_history]  WITH CHECK ADD  CONSTRAINT [CK_benefit_status_history_to_status] CHECK  (([to_status]='archived' OR [to_status]='expired' OR [to_status]='rejected' OR [to_status]='inactive' OR [to_status]='active' OR [to_status]='approved' OR [to_status]='under_review' OR [to_status]='pending_review' OR [to_status]='draft'))
GO

ALTER TABLE [dbo].[benefit_status_history] CHECK CONSTRAINT [CK_benefit_status_history_to_status]
GO


