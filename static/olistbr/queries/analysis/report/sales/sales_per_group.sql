USE olist;
GO

-- ==================================================
-- sales per product category
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
sales per
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
