USE SchoolDB;
GO

EXEC sp_addpublication
    @publication = N'StudentPublication_North',
    @status = N'active',
    @allow_push = N'true',
    @allow_pull = N'true',
    @repl_freq = N'continuous',
    @independent_agent = N'true',
    @immediate_sync = N'true';
GO

EXEC sp_addarticle
    @publication = N'StudentPublication_North',
    @article = N'Student_North',
    @source_owner = N'dbo',
    @source_object = N'Student',
    @type = N'logbased';
GO

EXEC sp_articlefilter
    @publication = N'StudentPublication_North',
    @article = N'Student_North',
    @filter_name = N'FLT_Student_North',
    @filter_clause = N'Region = ''North''';
GO

EXEC sp_articleview
    @publication = N'StudentPublication_North',
    @article = N'Student_North',
    @filter_clause = N'Region = ''North''';
GO
