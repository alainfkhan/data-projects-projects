USE olist;
GO

-- ==================================================
-- revenue per date per seller
SELECT
    s.year_number,
    s.month_number,
    s.seller_id,
    n.seller_gen_name,
    COUNT(DISTINCT s.order_id) AS order_count,
    SUM(s.price) AS product_revenue,
    SUM(s.freight_value) AS freight_revenue,
    SUM(s.price + s.freight_value) AS total_revenue
FROM sales.vw_sales_practical AS s
    LEFT JOIN sales.dim_seller_gen_names AS n
        ON s.seller_id = n.seller_id
GROUP BY
    s.year_number,
    s.month_number,
    s.seller_id,
    n.seller_gen_name
ORDER BY
    s.year_number,
    s.month_number,
    s.seller_id,
    n.seller_gen_name;
GO

-- ==================================================
-- top sellers by revenue
-- seller concentration
WITH cte_sellers AS (
    SELECT
        s.seller_id,
        n.seller_gen_name,
        s.order_id,
        s.price,
        s.freight_value,
        SUM(s.price + s.freight_value) OVER () AS dataset_total_revenue
    FROM sales.vw_sales_practical AS s
        LEFT JOIN sales.dim_seller_gen_names AS n
            ON s.seller_id = n.seller_id
),

agg_sellers AS (
    SELECT
        s.seller_id,
        s.seller_gen_name,
        COUNT(DISTINCT s.order_id) AS order_count,
        SUM(s.price) AS product_revenue,
        SUM(s.freight_value) AS freight_revenue,
        SUM(s.price + s.freight_value) AS total_revenue,
        s.dataset_total_revenue
    FROM cte_sellers AS s
    GROUP BY
        s.seller_id,
        s.seller_gen_name,
        s.dataset_total_revenue
),

calculate_sellers AS (
    SELECT
        s.*,
        s.total_revenue / s.order_count AS aov,
        s.total_revenue / s.dataset_total_revenue AS seller_concentration
    FROM agg_sellers AS s
)

SELECT TOP 10
    s.seller_id,
    s.seller_gen_name,
    s.order_count AS total_sales,
    utils.fn_format_brl(s.total_revenue) AS gmv,
    utils.fn_format_brl(s.aov) AS aov,
    utils.fn_format_brl(s.total_revenue) AS total_revenue,
    FORMAT(s.seller_concentration, 'P') AS seller_concentration
FROM calculate_sellers AS s
ORDER BY s.total_revenue DESC;
GO
