EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Agent XPs', 1;
RECONFIGURE;
