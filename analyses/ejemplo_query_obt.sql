-- EJEMPLO DE QUERY ANALITICO: MODELO OBT (ONE BIG TABLE)
-- Analisis: Top 10 Pokemon mas poderosos por tipo con sus estadisticas

SELECT
    pokemon_name,
    type_primary,
    type_secondary,
    type_combination,
    power_tier,
    base_experience,
    height,
    weight,
    bmi_ratio,
    size_category,
    weight_class
FROM {{ ref('obt_pokemon_complete') }}
WHERE power_tier IN ('Legendary', 'Strong')
ORDER BY base_experience DESC
LIMIT 10;

-- EJEMPLO 2: Analisis por tipo
-- Promedio de estadisticas por tipo primario

SELECT
    type_primary,
    COUNT(*) AS total_pokemon,
    ROUND(AVG(base_experience), 2) AS avg_experience,
    ROUND(AVG(height), 2) AS avg_height,
    ROUND(AVG(weight), 2) AS avg_weight,
    ROUND(AVG(bmi_ratio), 2) AS avg_bmi,
    SUM(CASE WHEN is_dual_type THEN 1 ELSE 0 END) AS dual_type_count
FROM {{ ref('obt_pokemon_complete') }}
GROUP BY type_primary
ORDER BY avg_experience DESC;

-- EJEMPLO 3: Analisis multidimensional complejo
-- Pokemon dual-type, legendarios, y grandes

SELECT
    pokemon_name,
    type_combination,
    power_tier,
    size_category,
    weight_class,
    base_experience,
    height,
    weight,
    CASE
        WHEN is_dual_type AND power_tier = 'Legendary' AND size_category = 'Large'
            THEN 'Elite Pokemon'
        WHEN is_dual_type AND power_tier = 'Legendary'
            THEN 'Legendary Dual-Type'
        WHEN power_tier = 'Legendary'
            THEN 'Legendary'
        ELSE 'Standard'
    END AS pokemon_classification
FROM {{ ref('obt_pokemon_complete') }}
WHERE is_dual_type = TRUE
ORDER BY base_experience DESC;

-- EJEMPLO 4: Distribucion por categorias
-- Resumen rapido de distribuciones

SELECT
    power_tier,
    size_category,
    weight_class,
    COUNT(*) AS total,
    ROUND(AVG(base_experience), 2) AS avg_experience
FROM {{ ref('obt_pokemon_complete') }}
GROUP BY power_tier, size_category, weight_class
ORDER BY total DESC;
