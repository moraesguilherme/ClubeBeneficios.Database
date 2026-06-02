CREATE PROCEDURE [dbo].[usp_loyalty_events_admin_search]
    @Search varchar(150) = NULL,
    @ClientId uniqueidentifier = NULL,
    @EventType varchar(50) = NULL,
    @MovementType varchar(30) = NULL,
    @SourceType varchar(50) = NULL,
    @DateFrom datetime2(7) = NULL,
    @DateTo datetime2(7) = NULL,
    @PageNumber int = 1,
    @PageSize int = 20,
	@Sort varchar(30) = 'date_desc'
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 20;

	SET @Sort = ISNULL(NULLIF(@Sort, ''), 'date_desc');

	IF @Sort NOT IN ('date_desc', 'customer_asc', 'points_desc', 'points_asc')
		SET @Sort = 'date_desc';

    ;WITH Filtered AS
    (
        SELECT
            e.id,
            e.client_id,
            c.full_name AS client_name,
            e.event_type,
            e.movement_type,
            e.source_type,
            e.source_id,
            e.source_reference,
            e.rule_id,
            r.name AS rule_name,
            e.campaign_id,
            ca.name AS campaign_name,
            e.reward_id,
            rw.title AS reward_title,
            e.adjustment_id,
            e.points_delta,
            e.monetary_amount,
            e.payment_method,
            e.payment_reference,
            e.occurred_at,
            e.effective_at,
            e.expires_at,
            e.is_expired,
            e.description,
            e.created_at,

            ir.service_type_raw AS service_type,
            ir.plan_name_raw AS plan_type,
            ir.package_name_raw AS package_type,
            ir.pet_name_raw AS pet_name,
            ir.customer_name_raw AS customer_name_raw,
            ir.source_sheet_name,
            ir.source_file_name,
            ir.row_number AS etl_row_number
        FROM dbo.customer_loyalty_events e
        INNER JOIN dbo.clients c 
            ON c.id = e.client_id
        LEFT JOIN dbo.loyalty_rules r 
            ON r.id = e.rule_id
        LEFT JOIN dbo.loyalty_campaigns ca 
            ON ca.id = e.campaign_id
        LEFT JOIN dbo.loyalty_rewards rw 
            ON rw.id = e.reward_id
        LEFT JOIN dbo.etl_import_rows ir
            ON ir.external_row_key = e.source_reference
           AND ir.is_current = 1
        WHERE (@Search IS NULL OR @Search = ''
                OR c.full_name LIKE '%' + @Search + '%'
                OR e.description LIKE '%' + @Search + '%'
                OR r.name LIKE '%' + @Search + '%'
                OR rw.title LIKE '%' + @Search + '%'
                OR ir.pet_name_raw LIKE '%' + @Search + '%'
                OR ir.service_type_raw LIKE '%' + @Search + '%'
                OR ir.plan_name_raw LIKE '%' + @Search + '%'
                OR ir.package_name_raw LIKE '%' + @Search + '%')
          AND (@ClientId IS NULL OR e.client_id = @ClientId)
          AND (@EventType IS NULL OR @EventType = '' OR e.event_type = @EventType)
          AND (@MovementType IS NULL OR @MovementType = '' OR e.movement_type = @MovementType)
          AND (@SourceType IS NULL OR @SourceType = '' OR e.source_type = @SourceType)
          AND (@DateFrom IS NULL OR e.effective_at >= @DateFrom)
          AND (@DateTo IS NULL OR e.effective_at < DATEADD(DAY, 1, @DateTo))
    ),
    Numbered AS
    (
        SELECT
            *,
            total_rows = COUNT(1) OVER(),
            row_num = ROW_NUMBER() OVER (
				ORDER BY
					CASE WHEN @Sort = 'customer_asc' THEN client_name END ASC,
					CASE WHEN @Sort = 'points_desc' THEN points_delta END DESC,
					CASE WHEN @Sort = 'points_asc' THEN points_delta END ASC,
					effective_at DESC,
					created_at DESC,
					id DESC
			)
        FROM Filtered
    )
    SELECT *
    FROM Numbered
    WHERE row_num BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END;
GO

