/* scratch
ctrl + shift + e to run

USE olist;
SELECT * FROM sys.schemas;
SELECT * FROM sys.tables;

-- view tables in a schema
SELECT *
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id;

-- view table schema
EXEC sp_help 'sales.order_items';

*/
