USE olist;

-- sales definition
IF OBJECT_ID('sales.dim_order_status_realised_sales_classification') IS NOT NULL
BEGIN
    DROP TABLE sales.dim_order_status_realised_sales_classification
END

CREATE TABLE sales.dim_order_status_realised_sales_classification (
    order_status VARCHAR(20) PRIMARY KEY,
    is_realised_sale BIT
)

INSERT INTO sales.dim_order_status_realised_sales_classification
VALUES
    ('approved', 1),
    ('delivered', 1),
    ('created', 0),
    ('invoiced', 1),
    ('processing', 1),
    ('unavailable', 0),
    ('canceled', 0),
    ('shipped', 1)
