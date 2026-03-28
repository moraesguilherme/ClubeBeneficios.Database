/*
ObservaÃ§Ã£o importante para SSDT / SQL Project:

As FKs cruzadas abaixo podem ser adicionadas em um arquivo complementar,
caso seu ambiente exija separar referÃªncias cÃ­clicas:

ALTER TABLE dbo.partners
    ADD CONSTRAINT FK_partners_created_by_user
    FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id);

ALTER TABLE dbo.partners
    ADD CONSTRAINT FK_partners_approved_by_user
    FOREIGN KEY (approved_by_user_id) REFERENCES dbo.users(id);

ALTER TABLE dbo.partners
    ADD CONSTRAINT FK_partners_rejected_by_user
    FOREIGN KEY (rejected_by_user_id) REFERENCES dbo.users(id);

Em muitos cenÃ¡rios de Database Project, o SSDT resolve a ordem sozinho.
*/
