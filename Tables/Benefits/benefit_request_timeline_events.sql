CREATE TABLE [dbo].[benefit_request_timeline_events](
	[id] [uniqueidentifier] NOT NULL,
	[benefit_request_id] [uniqueidentifier] NOT NULL,
	[event_type] [varchar](50) NOT NULL,
	[event_status] [varchar](30) NULL,
	[event_point] [varchar](200) NULL,
	[event_description] [varchar](1500) NULL,
	[actor_user_id] [uniqueidentifier] NULL,
	[occurred_at] [datetime2](7) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefit_request_timeline_events] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[benefit_request_timeline_events] ADD  CONSTRAINT [DF_benefit_request_timeline_events_id]  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[benefit_request_timeline_events] ADD  CONSTRAINT [DF_benefit_request_timeline_events_occurred_at]  DEFAULT (sysutcdatetime()) FOR [occurred_at]
GO
ALTER TABLE [dbo].[benefit_request_timeline_events] ADD  CONSTRAINT [DF_benefit_request_timeline_events_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[benefit_request_timeline_events]  WITH CHECK ADD  CONSTRAINT [FK_benefit_request_timeline_events_requests] FOREIGN KEY([benefit_request_id])
REFERENCES [dbo].[benefit_requests] ([id])
GO
ALTER TABLE [dbo].[benefit_request_timeline_events] CHECK CONSTRAINT [FK_benefit_request_timeline_events_requests]
GO
ALTER TABLE [dbo].[benefit_request_timeline_events]  WITH CHECK ADD  CONSTRAINT [FK_benefit_request_timeline_events_users] FOREIGN KEY([actor_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[benefit_request_timeline_events] CHECK CONSTRAINT [FK_benefit_request_timeline_events_users]
GO
ALTER TABLE [dbo].[benefit_request_timeline_events]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_timeline_events_status] CHECK  (([event_status] IS NULL OR ([event_status]='reversed' OR [event_status]='used' OR [event_status]='confirmed' OR [event_status]='converted_to_usage' OR [event_status]='no_show' OR [event_status]='scheduled' OR [event_status]='expired' OR [event_status]='cancelled' OR [event_status]='declined' OR [event_status]='rejected' OR [event_status]='approved' OR [event_status]='under_review' OR [event_status]='pending_review' OR [event_status]='requested')))
GO
ALTER TABLE [dbo].[benefit_request_timeline_events] CHECK CONSTRAINT [CK_benefit_request_timeline_events_status]
GO
ALTER TABLE [dbo].[benefit_request_timeline_events]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_timeline_events_type] CHECK  (([event_type]='review_added' OR [event_type]='status_changed' OR [event_type]='usage_cancelled' OR [event_type]='usage_confirmed' OR [event_type]='no_show' OR [event_type]='scheduled' OR [event_type]='expired' OR [event_type]='cancelled' OR [event_type]='rejected' OR [event_type]='approved' OR [event_type]='changes_requested' OR [event_type]='health_submitted' OR [event_type]='request_created'))
GO
ALTER TABLE [dbo].[benefit_request_timeline_events] CHECK CONSTRAINT [CK_benefit_request_timeline_events_type]
GO

