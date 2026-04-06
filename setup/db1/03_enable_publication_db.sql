USE SchoolDB;
GO

EXEC sp_replicationdboption
    @dbname = N'SchoolDB',
    @optname = N'publish',
    @value = N'true';
GO
