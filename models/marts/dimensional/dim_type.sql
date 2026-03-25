{{
    config(
        materialized='table'
    )
}}

-- Dimension: Type
-- Catalogo de todos los tipos de Pokemon
WITH pokemon_base AS (
    SELECT * FROM {{ ref('stg_pokemon') }}
),

types_extracted AS (
    SELECT DISTINCT
        types->0->'type'->>'name' AS type_name
    FROM pokemon_base

    UNION

    SELECT DISTINCT
        types->1->'type'->>'name' AS type_name
    FROM pokemon_base
    WHERE types->1->'type'->>'name' IS NOT NULL
),

final AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY type_name) AS type_id,
        type_name,
        CURRENT_TIMESTAMP AS created_at
    FROM types_extracted
    WHERE type_name IS NOT NULL
)

SELECT * FROM final
