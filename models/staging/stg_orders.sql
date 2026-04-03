with source as (
    select * from {{ source('raw', 'orders') }}
)
select
    cast(order_id as integer)       as order_id,
    cast(customer_id as integer)    as customer_id,
    cast(product_id as integer)     as product_id,
    cast(amount as decimal(10,2))   as amount,
    status,
    cast(created_at as timestamp)   as created_at,
    cast(created_at as date)        as order_date
from source
