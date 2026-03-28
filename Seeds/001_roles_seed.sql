IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE name = 'admin')
BEGIN
    INSERT INTO dbo.roles (id, name, description, created_at)
    VALUES (NEWID(), 'admin', 'Administrador da plataforma', SYSUTCDATETIME());
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE name = 'partner')
BEGIN
    INSERT INTO dbo.roles (id, name, description, created_at)
    VALUES (NEWID(), 'partner', 'UsuÃ¡rio parceiro', SYSUTCDATETIME());
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE name = 'client')
BEGIN
    INSERT INTO dbo.roles (id, name, description, created_at)
    VALUES (NEWID(), 'client', 'Cliente Matilha', SYSUTCDATETIME());
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE name = 'partner_customer')
BEGIN
    INSERT INTO dbo.roles (id, name, description, created_at)
    VALUES (NEWID(), 'partner_customer', 'Cliente do parceiro', SYSUTCDATETIME());
END
GO
