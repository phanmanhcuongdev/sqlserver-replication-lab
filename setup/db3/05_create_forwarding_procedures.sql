USE SchoolDB_South;
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
