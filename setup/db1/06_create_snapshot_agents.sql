USE SchoolDB;
GO

EXEC sp_addpublication_snapshot
    @publication = N'StudentPublication_North',
    @publisher_security_mode = 0,
    @publisher_login = N'sa',
    @publisher_password = N'Pcuong@2411';
GO

EXEC sp_addpublication_snapshot
    @publication = N'StudentPublication_South',
    @publisher_security_mode = 0,
    @publisher_login = N'sa',
    @publisher_password = N'Pcuong@2411';
GO
