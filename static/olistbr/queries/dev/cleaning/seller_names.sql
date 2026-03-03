/*
use ssms import wizard to import csv file
in olist_stg
saved as staging.

in ssms:
right click olist_stg
tasks
import flat file
specify input file
    'location of file to be imported'
        path/to/data/external/interim/claude_seller_names_260228.csv
    'new table name'
        dim_seller_gen_names
    'table schema'
        sales
    next
preview data
    use rich data type detection
    next
modify columns
    column name, data type, primary key, 0 allow nulls
    seller_id, char(32), 1, 0
    seller_gen_name, nvarchar(50), 0, 0
    no range
    next
summary
    finish
*/

SELECT
    n.*,
    m.*
FROM sales.dim_seller_gen_names AS n
    LEFT JOIN sales.dim_sellers AS m
        ON n.seller_id = m.seller_id;
