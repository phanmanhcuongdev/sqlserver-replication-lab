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
