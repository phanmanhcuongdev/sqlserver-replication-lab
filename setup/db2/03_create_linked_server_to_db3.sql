USE master;
GO

EXEC sp_addlinkedserver
    @server = 'DB3_LINK',
    @srvproduct = '',
    @provider = 'MSOLEDBSQL',
    @datasrc = 'db3';
GO

EXEC sp_addlinkedsrvlogin
    @rmtsrvname = 'DB3_LINK',
    @useself = 'false',
    @locallogin = NULL,
    @rmtuser = 'sa',
    @rmtpassword = 'Pcuong@2411';
GO

EXEC sp_serveroption 'DB3_LINK', 'data access', 'true';
EXEC sp_serveroption 'DB3_LINK', 'rpc', 'true';
EXEC sp_serveroption 'DB3_LINK', 'rpc out', 'true';
GO
