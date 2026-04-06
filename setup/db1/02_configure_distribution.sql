USE master;
GO

EXEC sp_adddistributor
    @distributor = @@SERVERNAME,
    @password = N'Pcuong@2411';
GO

EXEC sp_adddistributiondb
    @database = N'distribution',
    @data_folder = N'/var/opt/mssql/data',
    @log_folder = N'/var/opt/mssql/data';
GO

EXEC sp_adddistpublisher
    @publisher = @@SERVERNAME,
    @distribution_db = N'distribution',
    @security_mode = 0,
    @login = N'sa',
    @password = N'Pcuong@2411',
    @working_directory = N'/var/opt/mssql/ReplData';
GO
