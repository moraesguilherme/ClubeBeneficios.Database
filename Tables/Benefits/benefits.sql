CREATE TABLE [dbo].[benefits](
	[id] [uniqueidentifier] NOT NULL,
	[partner_id] [uniqueidentifier] NOT NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
	[updated_by_user_id] [uniqueidentifier] NULL,
	[approved_by_user_id] [uniqueidentifier] NULL,
	[rejected_by_user_id] [uniqueidentifier] NULL,
	[title] [varchar](180) NOT NULL,
	[benefit_type] [varchar](40) NOT NULL,
	[direction] [varchar](30) NOT NULL,
	[target_actor_type] [varchar](30) NOT NULL,
	[status] [varchar](30) NOT NULL,
	[short_description] [varchar](500) NULL,
	[full_description] [varchar](3000) NULL,
	[internal_notes] [varchar](max) NULL,
	[eligibility_type] [varchar](30) NOT NULL,
	[recurrence_type] [varchar](40) NOT NULL,
	[recurrence_value] [int] NULL,
	[recurrence_period] [varchar](20) NULL,
	[validity_type] [varchar](30) NOT NULL,
	[starts_at] [datetime2](7) NULL,
	[ends_at] [datetime2](7) NULL,
	[requires_manual_release] [bit] NOT NULL,
	[auto_activate_when_approved] [bit] NOT NULL,
	[highlight_in_showcase] [bit] NOT NULL,
	[allow_first_use_only] [bit] NOT NULL,
	[requires_active_access_code] [bit] NOT NULL,
	[requires_partner_availability] [bit] NOT NULL,
	[requires_matilha_acceptance_rules] [bit] NOT NULL,
	[stacking_rule] [varchar](30) NOT NULL,
	[approval_notes] [varchar](1500) NULL,
	[rejection_reason] [varchar](1500) NULL,
	[approved_at] [datetime2](7) NULL,
	[rejected_at] [datetime2](7) NULL,
	[inactivated_at] [datetime2](7) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefits] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[benefits] ADD  CONSTRAINT [DF_benefits_requires_manual_release]  DEFAULT ((0)) FOR [requires_manual_release]
GO

ALTER TABLE [dbo].[benefits] ADD  CONSTRAINT [DF_benefits_auto_activate_when_approved]  DEFAULT ((1)) FOR [auto_activate_when_approved]
GO

ALTER TABLE [dbo].[benefits] ADD  CONSTRAINT [DF_benefits_highlight_in_showcase]  DEFAULT ((0)) FOR [highlight_in_showcase]
GO

ALTER TABLE [dbo].[benefits] ADD  CONSTRAINT [DF_benefits_allow_first_use_only]  DEFAULT ((0)) FOR [allow_first_use_only]
GO

ALTER TABLE [dbo].[benefits] ADD  CONSTRAINT [DF_benefits_requires_active_access_code]  DEFAULT ((0)) FOR [requires_active_access_code]
GO

ALTER TABLE [dbo].[benefits] ADD  CONSTRAINT [DF_benefits_requires_partner_availability]  DEFAULT ((1)) FOR [requires_partner_availability]
GO

ALTER TABLE [dbo].[benefits] ADD  CONSTRAINT [DF_benefits_requires_matilha_acceptance_rules]  DEFAULT ((0)) FOR [requires_matilha_acceptance_rules]
GO

ALTER TABLE [dbo].[benefits] ADD  CONSTRAINT [DF_benefits_stacking_rule]  DEFAULT ('non_cumulative') FOR [stacking_rule]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [FK_benefits_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [FK_benefits_partners]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [FK_benefits_users_approved] FOREIGN KEY([approved_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [FK_benefits_users_approved]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [FK_benefits_users_created] FOREIGN KEY([created_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [FK_benefits_users_created]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [FK_benefits_users_rejected] FOREIGN KEY([rejected_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [FK_benefits_users_rejected]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [FK_benefits_users_updated] FOREIGN KEY([updated_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [FK_benefits_users_updated]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [CK_benefits_benefit_type] CHECK  (([benefit_type]='custom' OR [benefit_type]='experience' OR [benefit_type]='event' OR [benefit_type]='raffle' OR [benefit_type]='upgrade' OR [benefit_type]='evaluation' OR [benefit_type]='daily_rate' OR [benefit_type]='gift' OR [benefit_type]='service' OR [benefit_type]='discount'))
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [CK_benefits_benefit_type]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [CK_benefits_dates] CHECK  (([ends_at] IS NULL OR [starts_at] IS NULL OR [ends_at]>=[starts_at]))
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [CK_benefits_dates]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [CK_benefits_direction] CHECK  (([direction]='matilha_to_partner' OR [direction]='partner_to_matilha'))
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [CK_benefits_direction]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [CK_benefits_eligibility_type] CHECK  (([eligibility_type]='hybrid' OR [eligibility_type]='code' OR [eligibility_type]='behavior' OR [eligibility_type]='level' OR [eligibility_type]='open'))
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [CK_benefits_eligibility_type]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [CK_benefits_recurrence_period] CHECK  (([recurrence_period] IS NULL OR ([recurrence_period]='year' OR [recurrence_period]='semester' OR [recurrence_period]='quarter' OR [recurrence_period]='month' OR [recurrence_period]='week' OR [recurrence_period]='day')))
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [CK_benefits_recurrence_period]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [CK_benefits_recurrence_type] CHECK  (([recurrence_type]='first_use_only' OR [recurrence_type]='unlimited_within_rule' OR [recurrence_type]='limited_per_period' OR [recurrence_type]='once_per_customer'))
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [CK_benefits_recurrence_type]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [CK_benefits_recurrence_value] CHECK  (([recurrence_value] IS NULL OR [recurrence_value]>=(0)))
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [CK_benefits_recurrence_value]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [CK_benefits_stacking_rule] CHECK  (([stacking_rule]='allow_with_fidelity' OR [stacking_rule]='allow_with_campaign' OR [stacking_rule]='non_cumulative'))
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [CK_benefits_stacking_rule]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [CK_benefits_status] CHECK  (([status]='archived' OR [status]='expired' OR [status]='rejected' OR [status]='inactive' OR [status]='active' OR [status]='approved' OR [status]='under_review' OR [status]='pending_review' OR [status]='draft'))
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [CK_benefits_status]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [CK_benefits_target_actor_type] CHECK  (([target_actor_type]='partner_customer' OR [target_actor_type]='client'))
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [CK_benefits_target_actor_type]
GO

ALTER TABLE [dbo].[benefits]  WITH CHECK ADD  CONSTRAINT [CK_benefits_validity_type] CHECK  (([validity_type]='campaign_period' OR [validity_type]='until_stock' OR [validity_type]='date_range' OR [validity_type]='continuous'))
GO

ALTER TABLE [dbo].[benefits] CHECK CONSTRAINT [CK_benefits_validity_type]
GO


