CREATE DATABASE SchoolDB_North;
GO


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


USE SchoolDB_North;
GO

CREATE OR ALTER VIEW dbo.Student_Global
AS
SELECT StudentID, FullName, Region, BirthYear
FROM dbo.Student
UNION ALL
SELECT StudentID, FullName, Region, BirthYear
FROM OPENQUERY(DB3_LINK,
               'SELECT StudentID, FullName, Region, BirthYear
                FROM SchoolDB_South.dbo.Student');
GO


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


USE SchoolDB_North;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GlobalInsertStudent
    @StudentID INT,
    @FullName NVARCHAR(100),
    @Region VARCHAR(10),
    @BirthYear INT = NULL
    AS
BEGIN
EXEC DB1_LINK.SchoolDB.dbo.sp_GlobalInsertStudent
        @StudentID, @FullName, @Region, @BirthYear;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GlobalUpdateStudent
    @StudentID INT,
    @FullName NVARCHAR(100),
    @Region VARCHAR(10),
    @BirthYear INT = NULL
    AS
BEGIN
EXEC DB1_LINK.SchoolDB.dbo.sp_GlobalUpdateStudent
        @StudentID, @FullName, @Region, @BirthYear;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GlobalDeleteStudent
    @StudentID INT
    AS
BEGIN
EXEC DB1_LINK.SchoolDB.dbo.sp_GlobalDeleteStudent
        @StudentID;
END;
GO