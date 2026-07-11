CREATE TABLE [dbo].[client_level_rules](
	[id] [uniqueidentifier] NOT NULL,
	[level_code] [varchar](30) NOT NULL,
	[min_monthly_usage] [int] NULL,
	[max_monthly_usage] [int] NULL,
	[min_monthly_ticket] [decimal](18, 2) NULL,
	[max_monthly_ticket] [decimal](18, 2) NULL,
	[min_points_last_12m] [int] NULL,
	[max_points_last_12m] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_client_level_rules] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_client_level_rules_level_code] UNIQUE NONCLUSTERED 
(
	[level_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[client_level_rules]  WITH CHECK ADD  CONSTRAINT [CK_client_level_rules_level_code] CHECK  (([level_code]='platinum' OR [level_code]='diamond' OR [level_code]='gold' OR [level_code]='silver' OR [level_code]='bronze'))
GO
ALTER TABLE [dbo].[client_level_rules] CHECK CONSTRAINT [CK_client_level_rules_level_code]
GO

