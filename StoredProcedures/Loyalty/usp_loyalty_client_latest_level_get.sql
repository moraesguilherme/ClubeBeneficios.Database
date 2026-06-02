CREATE   PROCEDURE [dbo].[usp_loyalty_client_latest_level_get]
    @ClientId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

	SELECT TOP 1
		h.id,
		h.client_id,
		h.from_level_code AS previous_level_code,
		h.to_level_code AS current_level_code,
		h.change_reason,
		h.source_type,
		h.source_id,
		h.changed_at,
		h.created_at
	FROM dbo.loyalty_level_history h
	WHERE h.client_id = @ClientId
	ORDER BY h.changed_at DESC, h.created_at DESC;
END
GO

