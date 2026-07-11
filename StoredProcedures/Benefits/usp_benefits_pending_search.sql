CREATE   PROCEDURE [dbo].[usp_benefits_pending_search]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_benefits_pending_list
    ORDER BY created_at DESC;
END

GO

