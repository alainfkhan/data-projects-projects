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
