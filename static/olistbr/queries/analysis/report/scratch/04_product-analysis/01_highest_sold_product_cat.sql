USE olist_stg;

-- which product categories sell the most
/*
a sale is defined as
    order_status:
        'approved',
        'delivered',
        'invoiced',
        'processing',
        'shipped'
    and price is not null
*/


GO;

-- top 3 highest grossing product categories

WITH rev_by_pt AS (
    SELECT
        d.year_number,
        d.month_number,
        pt.product_category_name_english,
        COUNT(DISTINCT s.order_id) AS order_count,
        SUM(s.price) AS total_product_revenue,
        SUM(s.freight_value) AS total_freight_revenue,
        SUM(s.price + s.freight_value) AS total_revenue
    FROM sales.vw_sales AS s
        LEFT JOIN sales.dim_products AS p
            ON s.product_id = p.product_id
        LEFT JOIN sales.dim_product_category_name_translation AS pt
            ON p.product_category_name = pt.product_category_name
        RIGHT JOIN utils.dim_date AS d
            ON s.date_key = d.date_key
    GROUP BY
        d.year_number,
        d.month_number,
        pt.product_category_name_english
),

rn_rev AS (
    SELECT
        -- r.year_number,
        -- r.month_number,
        -- r.product_category_name_english,
        r.*,
        ROW_NUMBER() OVER (
            PARTITION BY
                r.year_number,
                r.month_number
            ORDER BY
                r.total_revenue DESC
        ) AS rn
    FROM rev_by_pt AS r
)
-- select
--     r.*
-- from rn_rev as r

SELECT
    r.year_number,
    r.month_number,
    r.rn AS top_category_rank,
    r.product_category_name_english,
    -- r.total_product_revenue,
    -- r.total_freight_revenue,
    r.total_revenue
INTO #top_categories
FROM rn_rev AS r
-- where r.rn between 1 and 3
ORDER BY
    r.year_number,
    r.month_number,
    r.rn

-- view table
SELECT *
FROM #top_categories
WHERE product_category_name_english IN ('pc_gamer')

-- which consistently appear in top n product categories?
SELECT
    t.product_category_name_english,
    COUNT(t.product_category_name_english) AS appearances,
    SUM(t.total_revenue) AS total_revenue
FROM #top_categories AS t
WHERE t.top_category_rank > 0
GROUP BY t.product_category_name_english
ORDER BY
    appearances DESC,
    total_revenue DESC


/*
health_beauty has consistently appeared the most out of all categories
*/


GO;
