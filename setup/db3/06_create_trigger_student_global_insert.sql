USE SchoolDB_South;
GO

CREATE OR ALTER TRIGGER trg_Student_Global_Insert
ON dbo.Student_Global
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @StudentID INT,
        @FullName NVARCHAR(100),
        @Region VARCHAR(10),
        @BirthYear INT;

    DECLARE cur_insert CURSOR LOCAL FAST_FORWARD FOR
    SELECT StudentID, FullName, Region, BirthYear
    FROM inserted;

    OPEN cur_insert;

    FETCH NEXT FROM cur_insert INTO @StudentID, @FullName, @Region, @BirthYear;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_GlobalInsertStudent
            @StudentID = @StudentID,
            @FullName = @FullName,
            @Region = @Region,
            @BirthYear = @BirthYear;

        FETCH NEXT FROM cur_insert INTO @StudentID, @FullName, @Region, @BirthYear;
    END

    CLOSE cur_insert;
    DEALLOCATE cur_insert;
END;
GO
