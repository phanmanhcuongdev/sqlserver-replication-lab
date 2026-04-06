CREATE OR ALTER TRIGGER trg_Student_Global_Update
ON dbo.Student_Global
INSTEAD OF UPDATE
                               AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
@StudentID INT,
        @FullName NVARCHAR(100),
        @Region VARCHAR(10),
        @BirthYear INT;

    DECLARE cur_update CURSOR LOCAL FAST_FORWARD FOR
SELECT StudentID, FullName, Region, BirthYear
FROM inserted;

OPEN cur_update;

FETCH NEXT FROM cur_update INTO @StudentID, @FullName, @Region, @BirthYear;
WHILE @@FETCH_STATUS = 0
BEGIN
EXEC dbo.sp_GlobalUpdateStudent
            @StudentID = @StudentID,
            @FullName = @FullName,
            @Region = @Region,
            @BirthYear = @BirthYear;

FETCH NEXT FROM cur_update INTO @StudentID, @FullName, @Region, @BirthYear;
END

CLOSE cur_update;
DEALLOCATE cur_update;
END;
GO
