-- Гипотеза: средняя оценка вина заметно зависит от региона
--
-- Регион = колонка province (Бургундия, Тоскана, Калифорния...), заполнена у всех вин.
-- Берём только регионы, где 200+ вин: у региона с 3 винами средняя оценка случайна.
-- Таких регионов 61, в них 94% всех вин.
--
-- Запрос 1 — топ-10 регионов по средней оценке:
--   Wachau (Австрия)       91.7   $47
--   Kamptal (Австрия)      91.4   $34
--   Rheingau (Германия)    91.0   $83
--   Kremstal (Австрия)     90.9   $30
--   Champagne (Франция)    90.3   $81
--   ...
--
-- Запрос 2 — 10 регионов с самой низкой средней оценкой:
--   Central Valley (Чили)  84.6   $12
--   Central Spain (Испания) 85.4  $18
--   Australia Other         85.5  $12
--   ...
--
-- Вывод: гипотеза подтвердилась. Разница между лучшим и худшим регионом — 7 баллов
-- (91.7 против 84.6), это примерно столько же, сколько между самыми дешёвыми
-- и самыми дорогими винами в анализе 01.
-- Интересно, что лучшие регионы — не обязательно самые дорогие: австрийские
-- Kamptal и Kremstal в топе при средней цене $30–34, а Бургундия ($73) только на 10-м месте.


-- 1. Топ-10 регионов по средней оценке
SELECT
    province,
    country,
    COUNT(*)                       AS wines,
    ROUND(AVG(points)::numeric, 1) AS avg_points,
    ROUND(AVG(price)::numeric, 0)  AS avg_price
FROM wines
GROUP BY province, country
HAVING COUNT(*) >= 200
ORDER BY avg_points DESC
LIMIT 10;


-- 2. 10 регионов с самой низкой средней оценкой
SELECT
    province,
    country,
    COUNT(*)                       AS wines,
    ROUND(AVG(points)::numeric, 1) AS avg_points,
    ROUND(AVG(price)::numeric, 0)  AS avg_price
FROM wines
GROUP BY province, country
HAVING COUNT(*) >= 200
ORDER BY avg_points ASC
LIMIT 10;
