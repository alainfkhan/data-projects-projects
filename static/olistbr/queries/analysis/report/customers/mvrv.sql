USE olist;
GO

/*
unreaslised count always >= realised count
never the case: unrealised count < realised count

WRONG, unrealised sale is complement of sale

*/

-- WRONG
WITH mv AS (
    SELECT
        o.year_number,
        o.month_number,
        COUNT(DISTINCT o.order_id) AS unrealised_orders,
        SUM(o.price) AS unrealised_product_revenue,
        SUM(o.freight_value) AS unrealised_freight_revenue,
        SUM(o.price + o.freight_value) AS unrealised_total_revenue
    FROM sales.vw_orders_practical AS o
    GROUP BY
        o.year_number,
        o.month_number
),

rv AS (
    SELECT
        s.year_number,
        s.month_number,
        COUNT(DISTINCT s.order_id) AS realised_orders,
        SUM(s.price) AS realised_product_revenue,
        SUM(s.freight_value) AS realised_freight_revenue,
        SUM(s.price + s.freight_value) AS realised_total_revenue
    FROM sales.vw_sales_practical AS s
    GROUP BY
        s.year_number,
        s.month_number
),

calculate_mvrv AS (
    SELECT
        mv.year_number,
        mv.month_number,
        1.0
        * mv.unrealised_orders
        / NULLIF(rv.realised_orders, 0) AS avg_mvrv_orders,
        1.0
        * mv.unrealised_product_revenue
        / NULLIF(rv.realised_product_revenue, 0) AS avg_mvrv_product_revenue,
        1.0
        * mv.unrealised_freight_revenue
        / NULLIF(rv.realised_freight_revenue, 0) AS avg_mvrv_freight_revenue,
        1.0
        * mv.unrealised_total_revenue
        / NULLIF(rv.realised_total_revenue, 0) AS avg_mvrv_total_revenue
    FROM mv
        FULL OUTER JOIN rv
            ON mv.year_number = rv.year_number
                AND mv.month_number = rv.month_number
)

SELECT c.*
FROM calculate_mvrv AS c
