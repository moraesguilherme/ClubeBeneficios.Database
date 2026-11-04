CREATE PROCEDURE [dbo].[usp_loyalty_client_redemptions_list]
    @ClientId uniqueidentifier,
    @Status varchar(30) = NULL,
    @PageNumber int = 1,
    @PageSize int = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 20;

    ;WITH Filtered AS
    (
        SELECT
            r.id AS redemption_id,
            r.client_id,
            r.reward_id,
            rw.title AS reward_title,
            r.redemption_code,

            r.requested_points_cost,
            r.approved_points_cost,

            r.status,

            status_label =
                CASE r.status
                    WHEN 'requested' THEN N'Solicitado'
                    WHEN 'under_review' THEN N'Em análise'
                    WHEN 'approved' THEN N'Aprovado'
                    WHEN 'rejected' THEN N'Rejeitado'
                    WHEN 'canceled' THEN N'Cancelado'
                    WHEN 'used' THEN N'Utilizado'
                    WHEN 'completed' THEN N'Concluído'
                    WHEN 'expired' THEN N'Expirado'
                    ELSE N'Situação não informada'
                END,

            status_description =
                CASE r.status
                    WHEN 'requested'
                        THEN N'Sua solicitação foi registrada e aguarda análise.'
                    WHEN 'under_review'
                        THEN N'Sua solicitação está sendo analisada pela equipe Matilha.'
                    WHEN 'approved'
                        THEN N'Sua recompensa foi aprovada. Consulte as condições de utilização.'
                    WHEN 'rejected'
                        THEN N'Sua solicitação não foi aprovada.'
                    WHEN 'canceled'
                        THEN N'Esta solicitação foi cancelada.'
                    WHEN 'used'
                        THEN N'A utilização desta recompensa foi registrada.'
                    WHEN 'completed'
                        THEN N'Esta solicitação foi concluída.'
                    WHEN 'expired'
                        THEN N'O prazo desta solicitação expirou.'
                    ELSE N'Consulte os detalhes desta solicitação.'
                END,

            r.request_channel,
            r.requested_at,

            reviewed_at =
                COALESCE(r.approved_at, r.rejected_at),

            r.approved_at,
            r.rejected_at,
            r.canceled_at,
            r.scheduled_for,
            r.used_at,
            r.completed_at,
            r.expires_at

        FROM dbo.loyalty_redemptions r
        INNER JOIN dbo.loyalty_rewards rw
            ON rw.id = r.reward_id

        WHERE r.client_id = @ClientId
          AND (
                @Status IS NULL
                OR @Status = ''
                OR r.status = @Status
              )
    ),
    Numbered AS
    (
        SELECT
            *,
            COUNT(1) OVER() AS total_rows,
            ROW_NUMBER() OVER (
                ORDER BY requested_at DESC, redemption_id DESC
            ) AS row_num
        FROM Filtered
    )
    SELECT
        redemption_id,
        client_id,
        reward_id,
        reward_title,
        redemption_code,

        requested_points_cost,
        approved_points_cost,

        status,
        status_label,
        status_description,

        request_channel,

        requested_at,
        reviewed_at,
        approved_at,
        rejected_at,
        canceled_at,
        scheduled_for,
        used_at,
        completed_at,
        expires_at,

        total_rows
    FROM Numbered
    WHERE row_num BETWEEN
        ((@PageNumber - 1) * @PageSize + 1)
        AND (@PageNumber * @PageSize)
    ORDER BY row_num;
END
GO