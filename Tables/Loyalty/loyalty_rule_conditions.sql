CREATE TABLE [dbo].[loyalty_rule_conditions](
	[id] [uniqueidentifier] NOT NULL,
	[rule_id] [uniqueidentifier] NOT NULL,
	[condition_type] [varchar](50) NOT NULL,
	[service_type] [varchar](50) NULL,
	[plan_type] [varchar](100) NULL,
	[package_type] [varchar](100) NULL,
	[payment_method] [varchar](50) NULL,
	[target_level_code] [varchar](30) NULL,
	[min_amount] [decimal](18, 2) NULL,
	[max_amount] [decimal](18, 2) NULL,
	[points_value] [decimal](18, 4) NULL,
	[currency_unit_amount] [decimal](18, 4) NULL,
	[multiplier_value] [decimal](18, 4) NULL,
	[window_type] [varchar](30) NULL,
	[window_value] [int] NULL,
	[json_payload] [nvarchar](max) NULL,
	[source_type] [varchar](50) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[application_scope] [varchar](30) NULL,
 CONSTRAINT [PK_loyalty_rule_conditions] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[loyalty_rule_conditions] ADD  CONSTRAINT [DF_loyalty_rule_conditions_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[loyalty_rule_conditions] ADD  CONSTRAINT [DF_loyalty_rule_conditions_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[loyalty_rule_conditions]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_rule_conditions_rules] FOREIGN KEY([rule_id])
REFERENCES [dbo].[loyalty_rules] ([id])
GO
ALTER TABLE [dbo].[loyalty_rule_conditions] CHECK CONSTRAINT [FK_loyalty_rule_conditions_rules]
GO
ALTER TABLE [dbo].[loyalty_rule_conditions]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rule_conditions_condition_type] CHECK  (([condition_type]='custom' OR [condition_type]='usage' OR [condition_type]='redemption' OR [condition_type]='eligibility' OR [condition_type]='pet_created' OR [condition_type]='pet_birthday' OR [condition_type]='client_birthday' OR [condition_type]='paid_amount' OR [condition_type]='payment' OR [condition_type]='amount' OR [condition_type]='level_gate' OR [condition_type]='level' OR [condition_type]='package' OR [condition_type]='plan' OR [condition_type]='service' OR [condition_type]='amount_range' OR [condition_type]='target_level' OR [condition_type]='payment_method' OR [condition_type]='package_type' OR [condition_type]='plan_type' OR [condition_type]='service_type'))
GO
ALTER TABLE [dbo].[loyalty_rule_conditions] CHECK CONSTRAINT [CK_loyalty_rule_conditions_condition_type]
GO
ALTER TABLE [dbo].[loyalty_rule_conditions]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rule_conditions_payment_method] CHECK  (([payment_method] IS NULL OR ([payment_method]='other' OR [payment_method]='boleto' OR [payment_method]='bank_transfer' OR [payment_method]='debit_card' OR [payment_method]='credit_card' OR [payment_method]='cash' OR [payment_method]='pix')))
GO
ALTER TABLE [dbo].[loyalty_rule_conditions] CHECK CONSTRAINT [CK_loyalty_rule_conditions_payment_method]
GO
ALTER TABLE [dbo].[loyalty_rule_conditions]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rule_conditions_source_type] CHECK  (([source_type] IS NULL OR ([source_type]='redemption' OR [source_type]='referral' OR [source_type]='manual' OR [source_type]='campaign' OR [source_type]='client_pet' OR [source_type]='client' OR [source_type]='etl_payment_row')))
GO
ALTER TABLE [dbo].[loyalty_rule_conditions] CHECK CONSTRAINT [CK_loyalty_rule_conditions_source_type]
GO
ALTER TABLE [dbo].[loyalty_rule_conditions]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rule_conditions_target_level_code] CHECK  (([target_level_code] IS NULL OR ([target_level_code]='diamond' OR [target_level_code]='gold' OR [target_level_code]='silver' OR [target_level_code]='bronze')))
GO
ALTER TABLE [dbo].[loyalty_rule_conditions] CHECK CONSTRAINT [CK_loyalty_rule_conditions_target_level_code]
GO
ALTER TABLE [dbo].[loyalty_rule_conditions]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rule_conditions_window_type] CHECK  (([window_type] IS NULL OR ([window_type]='year' OR [window_type]='semester' OR [window_type]='quarter' OR [window_type]='month' OR [window_type]='week' OR [window_type]='day')))
GO
ALTER TABLE [dbo].[loyalty_rule_conditions] CHECK CONSTRAINT [CK_loyalty_rule_conditions_window_type]
GO

