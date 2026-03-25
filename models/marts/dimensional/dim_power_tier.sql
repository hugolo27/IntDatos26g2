{{
    config(
        materialized='table'
    )
}}

-- Dimension: Power Tier
-- Clasificacion de Pokemon por nivel de poder basado en experiencia base
WITH tiers AS (
    SELECT 'Legendary' AS tier_name, 200 AS min_experience, 999999 AS max_experience, 1 AS tier_id
    UNION ALL
    SELECT 'Strong', 100, 199, 2
    UNION ALL
    SELECT 'Normal', 0, 99, 3
),

final AS (
    SELECT
        tier_id,
        tier_name,
        min_experience,
        max_experience,
        CURRENT_TIMESTAMP AS created_at
    FROM tiers
)

SELECT * FROM final
