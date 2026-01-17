CREATE TABLE sales.orders (
    order_id NVARCHAR(32) NOT NULL,
    customer_id NVARCHAR(32) NOT NULL,
    order_status NVARCHAR(20),
    order_purchase_timestamp DATETIME2,
    order_approved_at DATETIME2,
    order_delivered_carrier_date DATETIME2,
    order_delivered_customer_date DATETIME2,
    order_estimated_delivery_date DATETIME2,

    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id)
        REFERENCES sales.customers (customer_id)

);
