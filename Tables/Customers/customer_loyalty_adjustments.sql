CREATE TABLE [dbo].[customer_loyalty_adjustments](
	[id] [uniqueidentifier] NOT NULL,
	[client_id] [uniqueidentifier] NOT NULL,
	[adjustment_type] [varchar](30) NOT NULL,
	[points_delta] [int] NOT NULL,
	[reason] [varchar](500) NOT NULL,
	[notes] [varchar](1500) NULL,
	[status] [varchar](30) NOT NULL,
	[requested_at] [datetime2](7) NOT NULL,
	[requested_by_user_id] [uniqueidentifier] NULL,
	[decided_at] [datetime2](7) NULL,
	[decided_by_user_id] [uniqueidentifier] NULL,
	[decision_notes] [varchar](1500) NULL,
 CONSTRAINT [PK_customer_loyalty_adjustments] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments]  WITH CHECK ADD  CONSTRAINT [FK_customer_loyalty_adjustments_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments] CHECK CONSTRAINT [FK_customer_loyalty_adjustments_clients]
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments]  WITH CHECK ADD  CONSTRAINT [FK_customer_loyalty_adjustments_users_decided_by] FOREIGN KEY([decided_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments] CHECK CONSTRAINT [FK_customer_loyalty_adjustments_users_decided_by]
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments]  WITH CHECK ADD  CONSTRAINT [FK_customer_loyalty_adjustments_users_requested_by] FOREIGN KEY([requested_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments] CHECK CONSTRAINT [FK_customer_loyalty_adjustments_users_requested_by]
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_adjustments_adjustment_type] CHECK  (([adjustment_type]='debit' OR [adjustment_type]='credit'))
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments] CHECK CONSTRAINT [CK_customer_loyalty_adjustments_adjustment_type]
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_adjustments_dates] CHECK  (([decided_at] IS NULL OR [decided_at]>=[requested_at]))
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments] CHECK CONSTRAINT [CK_customer_loyalty_adjustments_dates]
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_adjustments_points_delta] CHECK  (([points_delta]<>(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments] CHECK CONSTRAINT [CK_customer_loyalty_adjustments_points_delta]
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_adjustments_status] CHECK  (([status]='cancelled' OR [status]='rejected' OR [status]='approved' OR [status]='pending_review'))
GO

ALTER TABLE [dbo].[customer_loyalty_adjustments] CHECK CONSTRAINT [CK_customer_loyalty_adjustments_status]
GO


