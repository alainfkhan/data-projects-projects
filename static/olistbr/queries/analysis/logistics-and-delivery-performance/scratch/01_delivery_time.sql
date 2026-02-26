use olist_stg;


-- average delivery time?
-- % of late deliveries?
-- delivery time by state?
-- freight cost vs distance?
-- does delivery time affect review score?

select
    sub.*,
    utils.fn_seconds_to_ddhhmmss(sub.avg_purchase_to_customer_s) as duration
from (
    select
        -- sub.*
        d.year_number,
        d.month_number,
        avg(sub.purchase_to_customer_s) as avg_purchase_to_customer_s
    from (
        select
            d.*,
            o.*,
            datediff_big(second, o.order_purchase_timestamp, o.order_delivered_customer_date) as purchase_to_customer_s
        from sales.fact_orders as o
        left join utils.dim_date as d
            on cast(o.order_purchase_timestamp as date) = d.key_date
        -- -- that are sales
        -- where o.order_id in (
        --     select distinct s.order_id
        --     from sales.vw_sales as s
        -- )
    ) as sub
    right join utils.dim_date as d
        on sub.date_key = d.date_key
    group by 
        d.year_number,
        d.month_number
) as sub
order by 
    sub.year_number,
    sub.month_number

/*
that are sales:
2016	9	4735860	54 days 19:31:00
2016	10	1693488	19 days 14:24:48
2016	11	NULL	NULL
2016	12	405477	4 days 16:37:57
2017	1	1092704	12 days 15:31:44
2017	2	1137786	13 days 04:03:06
2017	3	1118982	12 days 22:49:42
2017	4	1288907	14 days 22:01:47
2017	5	978252	11 days 07:44:12
2017	6	1037799	12 days 00:16:39
2017	7	1001612	11 days 14:13:32
2017	8	963111	11 days 03:31:51
2017	9	1023926	11 days 20:25:26
2017	10	1024418	11 days 20:33:38
2017	11	1309921	15 days 03:52:01
2017	12	1330120	15 days 09:28:40
2018	1	1216560	14 days 01:56:00
2018	2	1464059	16 days 22:40:59
2018	3	1408441	16 days 07:14:01
2018	4	993534	11 days 11:58:54
2018	5	986604	11 days 10:03:24
2018	6	798268	9 days 05:44:28
2018	7	774026	8 days 23:00:26
2018	8	668112	7 days 17:35:12
*/

