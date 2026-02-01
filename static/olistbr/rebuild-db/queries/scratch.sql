-- get current db
select db_name()

use olist_stg;
use deletesoon;
alter database deletesoon set multi_user

-- list all dbs
SELECT name FROM master.sys.databases 

-- list all tables in db
select *
from INFORMATION_SCHEMA.TABLES
where TABLE_TYPE='BASE TABLE'

select * from marketing.fact_marketing_qualified_leads

-- check how many connected to dbs
SELECT 
    DB_NAME(dbid) as DBName, 
    COUNT(dbid) as NumberOfConnections,
    loginame as LoginName
FROM
    sys.sysprocesses
WHERE 
    dbid > 0
GROUP BY 
    dbid, loginame
;

-- whats actively executing
exec sp_who2

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

SELECT 
    *
    -- session_id,
    -- login_name,
    -- host_name,
    -- program_name,
    -- status,
    -- last_request_start_time
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
    AND program_name LIKE '%python%'

select * from sys.sysprocesses

select * from sys.all_columns

use master

select db_name()

drop database olist_archived

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