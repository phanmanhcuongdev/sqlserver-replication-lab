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
