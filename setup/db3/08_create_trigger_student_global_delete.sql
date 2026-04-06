CREATE OR ALTER TRIGGER trg_Student_Global_Delete
ON dbo.Student_Global
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StudentID INT;

    DECLARE cur_delete CURSOR LOCAL FAST_FORWARD FOR
    SELECT StudentID
    FROM deleted;

    OPEN cur_delete;

    FETCH NEXT FROM cur_delete INTO @StudentID;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_GlobalDeleteStudent
            @StudentID = @StudentID;

        FETCH NEXT FROM cur_delete INTO @StudentID;
    END

    CLOSE cur_delete;
    DEALLOCATE cur_delete;
END;
GO
