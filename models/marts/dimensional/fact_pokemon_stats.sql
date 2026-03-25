{{
    config(
        materialized='table'
    )
}}

-- Tabla de Hechos: Pokemon Stats
-- Contiene las metricas cuantitativas de cada Pokemon
WITH pokemon_base AS (
    SELECT * FROM {{ ref('stg_pokemon') }}
),

pokemon_dim AS (
    SELECT * FROM {{ ref('dim_pokemon') }}
),

power_tiers AS (
    SELECT * FROM {{ ref('dim_power_tier') }}
),

pokemon_metrics AS (
    SELECT
        p.pokemon_id,
        p.height,
        p.weight,
        p.base_experience,
        -- Metricas calculadas
        ROUND(p.weight::DECIMAL / p.height::DECIMAL, 2) AS bmi_ratio,
        CASE
            WHEN p.height > 15 THEN 'Large'
            WHEN p.height > 8 THEN 'Medium'
            ELSE 'Small'
        END AS size_category,
        p.loaded_at
    FROM pokemon_base p
),

final AS (
    SELECT
        m.pokemon_id,
        pt.tier_id AS power_tier_id,
        m.height,
        m.weight,
        m.base_experience,
        m.bmi_ratio,
        m.size_category,
        m.loaded_at AS fact_created_at
    FROM pokemon_metrics m
    LEFT JOIN power_tiers pt
        ON m.base_experience BETWEEN pt.min_experience AND pt.max_experience
)

SELECT * FROM final
