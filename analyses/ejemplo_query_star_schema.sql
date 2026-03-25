-- EJEMPLO DE QUERY ANALITICO: MODELO DIMENSIONAL (STAR SCHEMA)
-- Analisis: Top 10 Pokemon mas poderosos por tipo con sus estadisticas

SELECT
    dp.pokemon_name,
    dp.type_primary,
    dp.type_secondary,
    dp.type_combination,
    pt.tier_name AS power_level,
    f.base_experience,
    f.height,
    f.weight,
    f.bmi_ratio,
    f.size_category
FROM {{ ref('fact_pokemon_stats') }} f
INNER JOIN {{ ref('dim_pokemon') }} dp
    ON f.pokemon_id = dp.pokemon_id
INNER JOIN {{ ref('dim_power_tier') }} pt
    ON f.power_tier_id = pt.tier_id
WHERE pt.tier_name IN ('Legendary', 'Strong')
ORDER BY f.base_experience DESC
LIMIT 10;

-- EJEMPLO 2: Analisis por tipo
-- Promedio de estadisticas por tipo primario

SELECT
    dp.type_primary,
    COUNT(DISTINCT dp.pokemon_id) AS total_pokemon,
    ROUND(AVG(f.base_experience), 2) AS avg_experience,
    ROUND(AVG(f.height), 2) AS avg_height,
    ROUND(AVG(f.weight), 2) AS avg_weight,
    ROUND(AVG(f.bmi_ratio), 2) AS avg_bmi
FROM {{ ref('fact_pokemon_stats') }} f
INNER JOIN {{ ref('dim_pokemon') }} dp
    ON f.pokemon_id = dp.pokemon_id
GROUP BY dp.type_primary
ORDER BY avg_experience DESC;

-- EJEMPLO 3: Distribucion de Pokemon por nivel de poder
-- Cuantos Pokemon hay en cada tier

SELECT
    pt.tier_name,
    COUNT(f.pokemon_id) AS total_pokemon,
    ROUND(AVG(f.base_experience), 2) AS avg_experience,
    MIN(f.base_experience) AS min_experience,
    MAX(f.base_experience) AS max_experience
FROM {{ ref('fact_pokemon_stats') }} f
INNER JOIN {{ ref('dim_power_tier') }} pt
    ON f.power_tier_id = pt.tier_id
GROUP BY pt.tier_name, pt.tier_id
ORDER BY pt.tier_id;
