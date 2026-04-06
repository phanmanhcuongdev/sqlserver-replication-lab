IF DB_ID('SchoolDB') IS NULL
    CREATE DATABASE SchoolDB;
GO

USE SchoolDB;
GO

IF OBJECT_ID('dbo.Student', 'U') IS NOT NULL
DROP TABLE dbo.Student;
GO

CREATE TABLE dbo.Student
(
    StudentID INT PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Region VARCHAR(10) NOT NULL,
    BirthYear INT NULL,
    CONSTRAINT CK_Student_Region CHECK (Region IN ('North', 'South'))
);
GO

INSERT INTO dbo.Student (StudentID, FullName, Region, BirthYear)
VALUES
(1, N'Nguyen Van A', 'North', 2004),
(2, N'Tran Thi B', 'North', 2005),
(3, N'Le Van C', 'South', 2003),
(4, N'Pham Thi D', 'South', 2004);
GO

SELECT * FROM dbo.Student;
GO



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





USE SchoolDB;
GO

EXEC sp_replicationdboption
    @dbname = N'SchoolDB',
    @optname = N'publish',
    @value = N'true';
GO


USE SchoolDB;
GO

EXEC sp_addpublication
    @publication = N'StudentPublication_North',
    @status = N'active',
    @allow_push = N'true',
    @allow_pull = N'true',
    @repl_freq = N'continuous',
    @independent_agent = N'true',
    @immediate_sync = N'true';
GO

EXEC sp_addarticle
    @publication = N'StudentPublication_North',
    @article = N'Student_North',
    @source_owner = N'dbo',
    @source_object = N'Student',
    @type = N'logbased';
GO

EXEC sp_articlefilter
    @publication = N'StudentPublication_North',
    @article = N'Student_North',
    @filter_name = N'FLT_Student_North',
    @filter_clause = N'Region = ''North''';
GO

EXEC sp_articleview
    @publication = N'StudentPublication_North',
    @article = N'Student_North',
    @filter_clause = N'Region = ''North''';
GO


USE SchoolDB;
GO

EXEC sp_addpublication
    @publication = N'StudentPublication_South',
    @status = N'active',
    @allow_push = N'true',
    @allow_pull = N'true',
    @repl_freq = N'continuous',
    @independent_agent = N'true',
    @immediate_sync = N'true';
GO

EXEC sp_addarticle
    @publication = N'StudentPublication_South',
    @article = N'Student_South',
    @source_owner = N'dbo',
    @source_object = N'Student',
    @type = N'logbased';
GO

EXEC sp_articlefilter
    @publication = N'StudentPublication_South',
    @article = N'Student_South',
    @filter_name = N'FLT_Student_South',
    @filter_clause = N'Region = ''South''';
GO

EXEC sp_articleview
    @publication = N'StudentPublication_South',
    @article = N'Student_South',
    @filter_clause = N'Region = ''South''';
GO

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


USE SchoolDB;
GO

EXEC sp_addsubscription
    @publication = N'StudentPublication_North',
    @subscriber = N'db2',
    @destination_db = N'SchoolDB_North',
    @subscription_type = N'Push',
    @sync_type = N'automatic',
    @article = N'all',
    @update_mode = N'read only';
GO

EXEC sp_addpushsubscription_agent
    @publication = N'StudentPublication_North',
    @subscriber = N'db2',
    @subscriber_db = N'SchoolDB_North',
    @subscriber_security_mode = 0,
    @subscriber_login = N'sa',
    @subscriber_password = N'Pcuong@2411',
    @frequency_type = 64,
    @frequency_interval = 0,
    @frequency_relative_interval = 0,
    @frequency_recurrence_factor = 0,
    @frequency_subday = 0,
    @frequency_subday_interval = 0,
    @active_start_time_of_day = 0,
    @active_end_time_of_day = 235959,
    @active_start_date = 20260406,
    @active_end_date = 99991231;
GO





USE SchoolDB;
GO

CREATE OR ALTER VIEW dbo.Student_Global
AS
SELECT StudentID, FullName, Region, BirthYear
FROM dbo.Student;
GO





USE SchoolDB;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GlobalInsertStudent
    @StudentID INT,
    @FullName NVARCHAR(100),
    @Region VARCHAR(10),
    @BirthYear INT = NULL
    AS
BEGIN
    SET NOCOUNT ON;

INSERT INTO dbo.Student (StudentID, FullName, Region, BirthYear)
VALUES (@StudentID, @FullName, @Region, @BirthYear);
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GlobalUpdateStudent
    @StudentID INT,
    @FullName NVARCHAR(100),
    @Region VARCHAR(10),
    @BirthYear INT = NULL
    AS
BEGIN
    SET NOCOUNT ON;

UPDATE dbo.Student
SET FullName = @FullName,
    Region = @Region,
    BirthYear = @BirthYear
WHERE StudentID = @StudentID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GlobalDeleteStudent
    @StudentID INT
    AS
BEGIN
    SET NOCOUNT ON;

DELETE FROM dbo.Student
WHERE StudentID = @StudentID;
END;
GO