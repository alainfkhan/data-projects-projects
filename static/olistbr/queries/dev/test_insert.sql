USE olist_stg;
GO

select * from sales.dim_customers

sp_help 'sales.dim_customers'


TRUNCATE table sales.dim_customers


INSERT INTO sales.dim_customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state) 
VALUES ('06b8999e2fba1a1fbc88172c00ba8bc7', '861eff4711a542e4b93843c6dd7febb0', '14409', 'franca', 'SP');