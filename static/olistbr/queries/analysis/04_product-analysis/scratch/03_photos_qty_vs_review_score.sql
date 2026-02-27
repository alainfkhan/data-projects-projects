USE olist_stg;

-- does photos qty affect review score?
/*

*/

WITH tbl_xy AS (
    SELECT DISTINCT
        -- p.product_id,
        p.product_photos_qty AS x,
        r.review_score AS y
    FROM sales.fact_orders AS o
    LEFT JOIN sales.fact_order_reviews AS r
        ON o.order_id = r.order_id
    LEFT JOIN sales.fact_order_items AS oi
        ON o.order_id = oi.order_id
    LEFT JOIN sales.dim_products AS p
        ON oi.product_id = p.product_id
    LEFT JOIN sales.dim_product_category_name_translation AS pt
        ON p.product_category_name = pt.product_category_name
    WHERE
        p.product_photos_qty IS NOT NULL
        AND r.review_score IS NOT NULL
)

SELECT
    -- t.*,
    (COUNT(*) * SUM(x * y) - SUM(x) * SUM(y))
    / (
        SQRT(COUNT(*) * SUM(SQUARE(x)) - SQUARE(SUM(x)))
        * SQRT(COUNT(*) * SUM(SQUARE(y)) - SQUARE(SUM(y)))
    ) AS corr_photos_qty_review_score
FROM tbl_xy AS t
-- order by
--     t.x,
--     t.y
