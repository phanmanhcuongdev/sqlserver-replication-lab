USE master;
GO

EXEC sp_addlinkedserver
    @server = 'DB2_LINK',
    @srvproduct = '',
    @provider = 'MSOLEDBSQL',
    @datasrc = 'db2';
GO

EXEC sp_addlinkedsrvlogin
    @rmtsrvname = 'DB2_LINK',
    @useself = 'false',
    @locallogin = NULL,
    @rmtuser = 'sa',
    @rmtpassword = 'Pcuong@2411';
GO

EXEC sp_serveroption 'DB2_LINK', 'data access', 'true';
EXEC sp_serveroption 'DB2_LINK', 'rpc', 'true';
EXEC sp_serveroption 'DB2_LINK', 'rpc out', 'true';
GO
