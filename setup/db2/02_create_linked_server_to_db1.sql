USE master;
GO

EXEC sp_addlinkedserver
    @server = 'DB1_LINK',
    @srvproduct = '',
    @provider = 'MSOLEDBSQL',
    @datasrc = 'db1';
GO

EXEC sp_addlinkedsrvlogin
    @rmtsrvname = 'DB1_LINK',
    @useself = 'false',
    @locallogin = NULL,
    @rmtuser = 'sa',
    @rmtpassword = 'Pcuong@2411';
GO

EXEC sp_serveroption 'DB1_LINK', 'rpc', 'true';
EXEC sp_serveroption 'DB1_LINK', 'rpc out', 'true';
EXEC sp_serveroption 'DB1_LINK', 'data access', 'true';
GO
