USE SchoolDB;
GO

EXEC sp_addsubscription
    @publication = N'StudentPublication_North',
    @subscriber = N'db2',
    @destination_db = N'SchoolDB_North',
    @subscription_type = N'Push',
    @sync_type = N'automatic',
    @article = N'all',
    @update_mode = N'read only';
GO

EXEC sp_addpushsubscription_agent
    @publication = N'StudentPublication_North',
    @subscriber = N'db2',
    @subscriber_db = N'SchoolDB_North',
    @subscriber_security_mode = 0,
    @subscriber_login = N'sa',
    @subscriber_password = N'Pcuong@2411',
    @frequency_type = 64,
    @frequency_interval = 0,
    @frequency_relative_interval = 0,
    @frequency_recurrence_factor = 0,
    @frequency_subday = 0,
    @frequency_subday_interval = 0,
    @active_start_time_of_day = 0,
    @active_end_time_of_day = 235959,
    @active_start_date = 20260406,
    @active_end_date = 99991231;
GO
