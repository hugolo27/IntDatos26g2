{{ config(materialized='table', schema='main_marts') }}

select
    country,
    count(distinct order_id)        as total_orders,
    round(sum(amount), 2)           as total_revenue,
    round(avg(amount), 2)           as avg_order_value
from {{ ref('fct_orders') }}
where status = 'completed'
group by country
order by total_revenue desc
