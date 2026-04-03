{{ config(materialized='table', schema='main_marts') }}

select
    product_name,
    category,
    count(distinct order_id)        as total_orders,
    round(sum(amount), 2)           as total_revenue,
    round(avg(amount), 2)           as avg_order_value,
    round(sum(margin), 2)           as total_margin
from {{ ref('fct_orders') }}
where status = 'completed'
group by product_name, category
order by total_revenue desc
