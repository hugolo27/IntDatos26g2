{{
    config(
        materialized='table'
    )
}}

-- Dimension: Pokemon
-- Contiene informacion descriptiva de cada Pokemon
WITH pokemon_base AS (
    SELECT * FROM {{ ref('stg_pokemon') }}
),

pokemon_with_types AS (
    SELECT
        pokemon_id,
        pokemon_name,
        types->0->'type'->>'name' AS type_primary,
        types->1->'type'->>'name' AS type_secondary
    FROM pokemon_base
),

final AS (
    SELECT
        pokemon_id,
        pokemon_name,
        type_primary,
        type_secondary,
        CASE
            WHEN type_secondary IS NOT NULL THEN type_primary || '/' || type_secondary
            ELSE type_primary
        END AS type_combination,
        CURRENT_TIMESTAMP AS created_at
    FROM pokemon_with_types
)

SELECT * FROM final
