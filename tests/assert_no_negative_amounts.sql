-- Test: ninguna orden debe tener monto negativo
select order_id, amount
from {{ ref('stg_orders') }}
where amount < 0
