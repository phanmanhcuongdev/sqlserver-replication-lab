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
