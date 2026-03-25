{{
    config(
        materialized='table'
    )
}}

-- One Big Table: Pokemon Complete
-- Tabla desnormalizada con toda la informacion para analisis rapido
WITH pokemon_base AS (
    SELECT * FROM {{ ref('stg_pokemon') }}
),

pokemon_enriched AS (
    SELECT
        -- IDs y nombres
        pokemon_id,
        pokemon_name,

        -- Tipos
        types->0->'type'->>'name' AS type_primary,
        types->1->'type'->>'name' AS type_secondary,
        CASE
            WHEN types->1->'type'->>'name' IS NOT NULL
                THEN types->0->'type'->>'name' || '/' || types->1->'type'->>'name'
            ELSE types->0->'type'->>'name'
        END AS type_combination,

        -- Metricas fisicas
        height,
        weight,
        base_experience,

        -- Metricas calculadas
        ROUND(weight::DECIMAL / height::DECIMAL, 2) AS bmi_ratio,

        -- Categorizaciones
        CASE
            WHEN height > 15 THEN 'Large'
            WHEN height > 8 THEN 'Medium'
            ELSE 'Small'
        END AS size_category,

        CASE
            WHEN base_experience >= 200 THEN 'Legendary'
            WHEN base_experience >= 100 THEN 'Strong'
            ELSE 'Normal'
        END AS power_tier,

        CASE
            WHEN weight > 1000 THEN 'Heavyweight'
            WHEN weight > 500 THEN 'Middleweight'
            ELSE 'Lightweight'
        END AS weight_class,

        -- Flags booleanos
        CASE WHEN types->1->'type'->>'name' IS NOT NULL THEN TRUE ELSE FALSE END AS is_dual_type,

        CASE
            WHEN types->0->'type'->>'name' IN ('fire', 'water', 'grass') THEN TRUE
            ELSE FALSE
        END AS is_starter_type,

        -- Metadata
        loaded_at,
        CURRENT_TIMESTAMP AS transformed_at

    FROM pokemon_base
)

SELECT * FROM pokemon_enriched
