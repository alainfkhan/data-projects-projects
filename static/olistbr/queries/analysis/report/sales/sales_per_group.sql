USE olist;
GO

-- ==================================================
-- sales per product category
WITH agg_sales AS (
    SELECT
        p.product_category_name,
        pt.product_category_name_english,
        COUNT(DISTINCT s.order_id) AS order_count,
        SUM(s.price) AS product_revenue,
        SUM(s.freight_value) AS freight_revenue,
        SUM(s.price + freight_value) AS total_revenue
    FROM sales.vw_sales_practical AS s
        LEFT JOIN sales.dim_products AS p
            ON s.product_id = p.product_id
        LEFT JOIN sales.dim_product_category_name_translation AS pt
            ON p.product_category_name = pt.product_category_name
    GROUP BY
        p.product_category_name,
        pt.product_category_name_english
),

dataset_totals AS (
    SELECT
        COUNT(DISTINCT s.order_id) AS dataset_total_order_counts,
        SUM(s.price) AS dataset_total_product_revenue,
        SUM(s.freight_value) AS dataset_total_freight_revenue,
        SUM(s.price + s.freight_value) AS dataset_total_revenue
    FROM sales.vw_sales_practical AS s
)

SELECT
    s.product_category_name,
    s.product_category_name_english,
    s.order_count AS total_sales,
    utils.fn_format_brl(s.total_revenue) AS gmv,
    FORMAT(s.total_revenue / s.order_count, 'R$0.00') AS aov,
    FORMAT(s.total_revenue / dst.dataset_total_revenue, 'P')
        AS product_category_concentration
FROM agg_sales AS s
    CROSS JOIN dataset_totals AS dst
ORDER BY s.total_revenue DESC;
GO

-- ==================================================
-- sales per date per product category
SELECT
    s.year_number,
    s.month_number,
    p.product_category_name,
    COUNT(DISTINCT s.order_id) AS order_count,
    SUM(s.price) AS product_revenue,
    SUM(s.freight_value) AS freight_revenue,
    SUM(s.price + s.freight_value) AS total_revenue
FROM sales.vw_sales_practical AS s
LEFT JOIN sales.dim_products AS p
    ON s.product_id = p.product_id
GROUP BY
    s.year_number,
    s.month_number,
    p.product_category_name
ORDER BY
    s.year_number,
    s.month_number,
    p.product_category_name;
GO

-- ==================================================
/*
sales per date per
    business segment
    business type
*/
SELECT
    s.year_number,
    s.month_number,
    cd.business_segment,
    COUNT(DISTINCT s.order_id) AS order_count,
    SUM(s.price) AS product_revenue,
    SUM(s.freight_value) AS freight_revenue,
    SUM(s.price + s.freight_value) AS total_revenue
FROM sales.vw_sales_practical AS s
LEFT JOIN marketing.fact_closed_deals AS cd
    ON s.seller_id = cd.seller_id
GROUP BY
    s.year_number,
    s.month_number,
    cd.business_segment
ORDER BY
    s.year_number,
    s.month_number,
    cd.business_segment;
GO

-- ==================================================
-- revenue per customer state
WITH customer_state_revenues AS (
    SELECT
        c.customer_state,
        -- sum(s.price) as product_expenditure,
        -- sum(s.freight_value) as freight_expenditure,
        SUM(s.price + s.freight_value) AS total_expenditure
    FROM sales.vw_sales_practical AS s
        LEFT JOIN sales.dim_customers AS c
            ON s.customer_id = c.customer_id
    WHERE c.customer_state IS NOT NULL
    GROUP BY c.customer_state
),

-- revenue per seller state
seller_state_revenues AS (
    SELECT
        c.seller_state,
        -- sum(s.price) as product_revenue,
        -- sum(s.freight_value) as freight_revenue,
        SUM(s.price + s.freight_value) AS total_revenue
    FROM sales.vw_sales_practical AS s
        LEFT JOIN sales.dim_sellers AS c
            ON s.seller_id = c.seller_id
    WHERE c.seller_state IS NOT NULL
    GROUP BY c.seller_state
)

SELECT
    -- c.*,
    -- s.*
    c.customer_state AS uf,
    utils.fn_format_brl(c.total_expenditure) AS total_expenditure,
    utils.fn_format_brl(s.total_revenue) AS total_revenue
FROM customer_state_revenues AS c
    LEFT JOIN seller_state_revenues AS s
        ON c.customer_state = s.seller_state
ORDER BY c.customer_state ASC;
GO
