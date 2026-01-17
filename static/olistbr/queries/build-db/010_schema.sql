USE olist;
GO

-- ==================================================
-- Create Schemas
-- ==================================================

CREATE SCHEMA sales;
GO

CREATE SCHEMA marketing;
GO

CREATE SCHEMA logistics;
GO

-- ==================================================
-- Create Tables
-- --v means verified
-- ==================================================

-- ==========
-- Sales
-- ==========

-- TODO: finish datatype verifications
CREATE TABLE sales.customers (
    customer_id NVARCHAR(32) NOT NULL,          --v
    customer_unique_id NVARCHAR(32) NOT NULL,   --v
    customer_zip_code_prefix CHAR(5),           --v
    customer_city NVARCHAR(100),
    customer_state NVARCHAR(2),
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
); --v

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
); --v

CREATE TABLE sales.products (
    product_id NVARCHAR(32) NOT NULL,
    product_category_name NVARCHAR(255),
    product_name_lenght TINYINT,
    product_description_lenght SMALLINT,
    product_photos_qty TINYINT,
    product_weight_g INT,
    product_length_cm TINYINT,
    product_height_cm TINYINT,
    product_width_cm TINYINT,
    CONSTRAINT pk_products PRIMARY KEY (product_id)
); --v

CREATE TABLE sales.order_items (
    order_id NVARCHAR(32) NOT NULL,
    order_item_id TINYINT NOT NULL,
    product_id NVARCHAR(32) NOT NULL,
    seller_id NVARCHAR(32) NOT NULL,
    shipping_limit_date DATETIME2,
    price DECIMAL(10, 2),
    freight_value DECIMAL(10, 2),
    CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_order_items_orders FOREIGN KEY (order_id)
        REFERENCES sales.orders (order_id)
);

CREATE TABLE sales.order_payments (
    order_id NVARCHAR(32) NOT NULL,
    payment_sequential TINYINT NOT NULL,
    payment_type NVARCHAR(20),
    payment_installments TINYINT,
    payment_value DECIMAL(10, 2)
    CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE sales.order_reviews (
    review_id NVARCHAR(32) NOT NULL,
    order_id NVARCHAR(32) NOT NULL,
    review_score TINYINT,
    review_comment_title NVARCHAR(255),
    review_comment_message NVARCHAR(MAX),
    review_creation_date DATETIME2,
    review_answer_timestamp DATETIME2,
    CONSTRAINT pk_order_reviews PRIMARY KEY (review_id)
);


CREATE TABLE sales.sellers (
    seller_id NVARCHAR(32) NOT NULL,
    seller_zip_code_prefix NVARCHAR(10),
    seller_city NVARCHAR(100),
    seller_state NVARCHAR(2),
    CONSTRAINT pk_sellers PRIMARY KEY (seller_id)
);

CREATE TABLE sales.product_category_name_translation (
    product_category_name NVARCHAR(50) NOT NULL,
    product_category_name_english NVARCHAR(50)
    CONSTRAINT pk_product_category_name_translation PRIMARY KEY (
        product_category_name
    )
);

-- ==========
-- Marketing
-- ==========

CREATE TABLE marketing.marketing_qualified_leads (
    mql_id NVARCHAR(32) NOT NULL,
    first_contact_date DATE,
    landing_page_id NVARCHAR(32),
    origin NVARCHAR(50),
    CONSTRAINT pk_marketing_qualified_leads PRIMARY KEY (mql_id)
);


CREATE TABLE marketing.closed_deals (
    mql_id NVARCHAR(32) NOT NULL,
    seller_id NVARCHAR(32),
    sdr_id NVARCHAR(32),
    sr_id NVARCHAR(32),
    won_date DATETIME2,
    business_segment NVARCHAR(100),
    lead_type NVARCHAR(50),
    lead_behaviour_profile NVARCHAR(50),
    has_company BIT,
    has_gtin BIT,
    average_stock NVARCHAR(50),
    business_type NVARCHAR(50),
    declared_product_catalog_size DECIMAL(10, 1),
    declared_monthly_revenue DECIMAL(12, 2),
    CONSTRAINT pk_closed_deals PRIMARY KEY (mql_id)
);

-- ==========
-- Logistics
-- ==========

CREATE TABLE logistics.geolocation (
    geolocation_zip_code_prefix NVARCHAR(10) NOT NULL,
    geolocation_lat DECIMAL(9, 6),
    geolocation_lng DECIMAL(9, 6),
    geolocation_city NVARCHAR(100),
    geolocation_state NVARCHAR(2),
);

/* scratch

SELECT * FROM sys.schemas;
SELECT * FROM sys.tables;

-- view tables in a schema
SELECT *
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id;

-- view table schema
EXEC sp_help 'sales.order_items';

*/
