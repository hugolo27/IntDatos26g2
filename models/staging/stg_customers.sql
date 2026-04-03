with source as (
    select * from {{ source('raw', 'customers') }}
)
select
    cast(customer_id as integer)    as customer_id,
    name,
    email,
    country,
    cast(created_at as timestamp)   as created_at
from source
