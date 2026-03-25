-- Test: Pokemon should not have negative height or weight values
-- This test fails if it returns any rows

select
    pokemon_id,
    pokemon_name,
    height,
    weight
from {{ ref('stg_pokemon') }}
where height < 0
   or weight < 0
