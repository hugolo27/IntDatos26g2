-- Test: todos los estados deben ser valores válidos
select order_id, status
from {{ ref('stg_orders') }}
where status not in ('completed', 'pending', 'cancelled')
