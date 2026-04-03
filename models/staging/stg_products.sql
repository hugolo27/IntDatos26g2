with source as (
    select * from {{ source('raw', 'products') }}
)
select
    cast(product_id as integer)     as product_id,
    name                            as product_name,
    category,
    cast(price as decimal(10,2))    as price
from source
