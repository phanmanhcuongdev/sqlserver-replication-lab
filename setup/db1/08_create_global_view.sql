USE SchoolDB;
GO

CREATE OR ALTER VIEW dbo.Student_Global
AS
SELECT StudentID, FullName, Region, BirthYear
FROM dbo.Student;
GO
