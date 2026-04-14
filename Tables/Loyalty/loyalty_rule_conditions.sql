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
 CONSTRAINT [PK_loyalty_rule_conditions] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[loyalty_rule_conditions]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_rule_conditions_rules] FOREIGN KEY([rule_id])
REFERENCES [dbo].[loyalty_rules] ([id])
GO

ALTER TABLE [dbo].[loyalty_rule_conditions] CHECK CONSTRAINT [FK_loyalty_rule_conditions_rules]
GO

ALTER TABLE [dbo].[loyalty_rule_conditions]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rule_conditions_condition_type] CHECK  (([condition_type]='custom' OR [condition_type]='referral' OR [condition_type]='signup' OR [condition_type]='anniversary' OR [condition_type]='level_gate' OR [condition_type]='campaign' OR [condition_type]='payment' OR [condition_type]='service'))
GO

ALTER TABLE [dbo].[loyalty_rule_conditions] CHECK CONSTRAINT [CK_loyalty_rule_conditions_condition_type]
GO

ALTER TABLE [dbo].[loyalty_rule_conditions]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rule_conditions_payment_method] CHECK  (([payment_method] IS NULL OR ([payment_method]='other' OR [payment_method]='boleto' OR [payment_method]='bank_transfer' OR [payment_method]='debit_card' OR [payment_method]='credit_card' OR [payment_method]='cash' OR [payment_method]='pix')))
GO

ALTER TABLE [dbo].[loyalty_rule_conditions] CHECK CONSTRAINT [CK_loyalty_rule_conditions_payment_method]
GO

ALTER TABLE [dbo].[loyalty_rule_conditions]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rule_conditions_target_level_code] CHECK  (([target_level_code] IS NULL OR ([target_level_code]='platinum' OR [target_level_code]='diamond' OR [target_level_code]='gold' OR [target_level_code]='silver' OR [target_level_code]='bronze')))
GO

ALTER TABLE [dbo].[loyalty_rule_conditions] CHECK CONSTRAINT [CK_loyalty_rule_conditions_target_level_code]
GO

ALTER TABLE [dbo].[loyalty_rule_conditions]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rule_conditions_window_type] CHECK  (([window_type] IS NULL OR ([window_type]='year' OR [window_type]='semester' OR [window_type]='quarter' OR [window_type]='month' OR [window_type]='week' OR [window_type]='day')))
GO

ALTER TABLE [dbo].[loyalty_rule_conditions] CHECK CONSTRAINT [CK_loyalty_rule_conditions_window_type]
GO


