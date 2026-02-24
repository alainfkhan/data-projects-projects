-- get current db
SELECT DB_NAME()

USE olist_stg;
USE deletesoon;
ALTER DATABASE deletesoon SET multi_user

-- list all dbs
SELECT name FROM master.sys.databases

-- list all tables in db
SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'

SELECT * FROM marketing.fact_marketing_qualified_leads

-- check how many connected to dbs
SELECT
    DB_NAME(dbid) AS dbname,
    COUNT(dbid) AS numberofconnections,
    loginame AS loginname
FROM
    sys.sysprocesses
WHERE
    dbid > 0
GROUP BY
    dbid, loginame
;

-- whats actively executing
EXEC sp_who2

-- check for active connections
SELECT
    session_id,
    login_name,
    host_name,
    program_name,
    status,
    last_request_start_time
FROM sys.dm_exec_sessions
WHERE is_user_process = 1

SELECT *
    -- session_id,
    -- login_name,
    -- host_name,
    -- program_name,
    -- status,
    -- last_request_start_time
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
    AND program_name LIKE '%python%'

SELECT * FROM sys.sysprocesses

SELECT * FROM sys.all_columns

USE master

SELECT DB_NAME()

DROP DATABASE olist_archived

SELECT
    session_id,
    login_name,
    host_name,
    program_name,
    status,
    login_time,
    last_request_start_time
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('olist_archived');
