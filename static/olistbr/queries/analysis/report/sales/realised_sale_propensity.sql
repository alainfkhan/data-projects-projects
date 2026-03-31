USE olist;
GO

-- ==================================================
-- realised sale
WITH realised_sales_count AS (
    SELECT
        k.is_realised_sale,
        COUNT(o.order_status) AS count_order_status
    FROM sales.fact_orders AS o
        LEFT JOIN sales.order_status_realised_sales_classification AS k
            ON o.order_status = k.order_status
    GROUP BY k.is_realised_sale
),

tbl_total_orders AS (
    SELECT COUNT(DISTINCT o.order_id) AS total_orders
    FROM sales.fact_orders AS o
)

SELECT
    r.is_realised_sale,
    r.count_order_status,
    FORMAT(1.0 * r.count_order_status / NULLIF(t.total_orders, 0), 'P3') AS pc
FROM realised_sales_count AS r
    CROSS JOIN tbl_total_orders AS t;
GO

-- ==================================================
-- price measurable
-- TODO: learn pivot table, need to finish pc

WITH count_price_nullness AS (
    SELECT
        SUM(CASE WHEN o.price IS NOT NULL
            THEN 1
        END) AS count_price_is_not_null,
        SUM(CASE WHEN o.price IS NULL
            THEN 1
        END) AS count_price_is_null
    FROM sales.vw_join_orders AS o
),
-- select n.*
-- from count_price_nullness as n

tbl_count_listed_prices AS (
    SELECT COUNT(*) AS count_listed_prices
    FROM sales.vw_join_orders AS o
)

SELECT
    n.count_price_is_null,
    n.count_price_is_not_null,
    t.count_listed_prices
FROM count_price_nullness AS n
    CROSS JOIN tbl_count_listed_prices AS t
