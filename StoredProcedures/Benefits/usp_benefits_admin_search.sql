SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_benefits_admin_search
    @Search VARCHAR(200) = NULL,
    @Direction VARCHAR(30) = NULL,
    @Status VARCHAR(30) = NULL,
    @PartnerId UNIQUEIDENTIFIER = NULL,
    @TargetActorType VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        *
    FROM dbo.vw_benefits_admin_list
    WHERE
        (@Search IS NULL OR title LIKE '%' + @Search + '%' OR partner_name LIKE '%' + @Search + '%')
        AND (@Direction IS NULL OR direction = @Direction)
        AND (@Status IS NULL OR status = @Status)
        AND (@PartnerId IS NULL OR partner_id = @PartnerId)
        AND (@TargetActorType IS NULL OR target_actor_type = @TargetActorType)
    ORDER BY created_at DESC;
END
GO