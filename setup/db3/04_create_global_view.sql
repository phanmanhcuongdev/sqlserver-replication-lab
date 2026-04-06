USE SchoolDB_South;
GO

CREATE OR ALTER VIEW dbo.Student_Global
AS
SELECT StudentID, FullName, Region, BirthYear
FROM dbo.Student
UNION ALL
SELECT StudentID, FullName, Region, BirthYear
FROM OPENQUERY(DB2_LINK,
               'SELECT StudentID, FullName, Region, BirthYear
                FROM SchoolDB_North.dbo.Student');
GO
