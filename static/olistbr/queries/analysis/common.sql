USE olist_stg;
GO

-- get current db
SELECT DB_NAME()
GO

-- list all databases
SELECT name
FROM master.sys.databases;
GO

-- list schemas
DECLARE @this_db VARCHAR(20) = DB_NAME();
DECLARE @sql NVARCHAR(MAX);
SET
    @sql
    = N' SELECT name as'
    + QUOTENAME(@this_db)
    + 'FROM sys.schemas WHERE schema_id BETWEEN 5 AND 16383;'
EXEC sp_sqlexec @sql;
GO

-- list schemas simple:
SELECT DB_NAME();
SELECT name
FROM sys.schemas
WHERE schema_id BETWEEN 5 AND 16383;
GO

-- list tables
SELECT
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
GO

-- list created temp tables
SELECT *
FROM TEMPDB.SYS.OBJECTS
WHERE [TYPE] = 'U'


-- list temp table schema
SELECT *
FROM TEMPDB.SYS.ALL_COLUMNS
WHERE OBJECT_ID = (
    SELECT OBJECT_ID
    FROM TEMPDB.SYS.TABLES
    WHERE NAME LIKE '#tmp_dim_geolocation_canon_ascii%'
)

-- list tables in a specific schema
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
AND TABLE_SCHEMA = 'logistics'
GO

-- view table schema
EXEC sp_help 'marketing.fact_closed_deals';

-- select top n
SELECT TOP 1000 *
FROM marketing.fact_closed_deals;

-- random analyses
-- get the longest review comment message
WITH cte AS (
SELECT --TOP 1000
    t.review_score,
    t.review_comment_title,
    t.review_comment_message,
    LEN(t.review_comment_message) AS len_message
FROM sales.fact_order_reviews AS t
WHERE t.review_comment_message IS NOT NULL AND t.review_score = 5
)

SELECT TOP 1000
    c.*,
    ROW_NUMBER()
        OVER (ORDER BY c.len_message DESC, c.review_comment_message ASC)
        AS row_number,
    RANK()
        OVER (ORDER BY c.len_message DESC, c.review_comment_message ASC)
        AS rank,
    DENSE_RANK()
        OVER (ORDER BY c.len_message DESC, c.review_comment_message ASC)
        AS dense_rank
FROM cte AS c

-- list collations
select *
from sys.fn_helpcollations()
where name like 'sql%'

-- get rows
select
    count(*)
from logistics.fact_geolocation

-- faster way of getting rows
select
    st.row_count
from sys.dm_db_partition_stats as st
where st.object_id = object_id('logistics.fact_geolocation')