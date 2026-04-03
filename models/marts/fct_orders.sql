{{ config(materialized='table', schema='main_marts') }}

with orders as (
    select * from {{ ref('stg_orders') }}
),
customers as (
    select * from {{ ref('stg_customers') }}
),
products as (
    select * from {{ ref('stg_products') }}
)
select
    o.order_id,
    o.created_at,
    o.order_date,
    o.status,
    o.amount,
    c.customer_id,
    c.name          as customer_name,
    c.country,
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    o.amount - p.price  as margin
from orders o
left join customers c on o.customer_id = c.customer_id
left join products p on o.product_id = p.product_id
