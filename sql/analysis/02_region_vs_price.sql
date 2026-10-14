-- Гипотеза: связь между регионом и ценой сильная
--
-- Регион = колонка province (Бургундия, Тоскана, Калифорния...), заполнена у всех вин.
--
-- Как измеряем связь: регион — это название, а не число, поэтому CORR(province, price)
-- посчитать нельзя. Вместо этого каждому вину ставим среднюю цену его региона
-- и считаем Пирсона между настоящей ценой и средней ценой региона.
-- Если регион сильно влияет на цену, то по средней цене региона цена вина хорошо угадывается и r высокий.
-- Шкала та же, что в 01: до 0.3 — слабая, 0.3–0.7 — умеренная, больше 0.7 — сильная.
--
-- Берём только регионы, где 200+ вин: у региона с 3 винами средняя цена случайна.
--
-- Запрос 1 — сила связи (61 регион, 104 272 вина с ценой):
--   регион и цена как есть       0.28
--   регион и логарифм цены       0.44
--
-- Запрос 2 — топ-10 регионов по средней оценке:
--   Wachau (Австрия)       91.7   $47
--   Kamptal (Австрия)      91.4   $34
--   Rheingau (Германия)    91.0   $83
--   Kremstal (Австрия)     90.9   $30
--   Champagne (Франция)    90.3   $81
--   ...
--   Burgundy (Франция)     89.6   $73
--
-- Вывод: гипотеза не подтвердилась. Связь региона и цены слабая (0.28),
-- а на логарифме цены умеренная (0.44), но не сильная: регион объясняет
-- около 19% разброса цен (0.44² ≈ 0.19), остальное зависит от других факторов.
-- Дополнительно: в топе по оценкам в основном австрийские и немецкие регионы, причём
-- не самые дорогие: Kamptal и Kremstal при средней цене $30–34, а Бургундия ($73) только на 10-м месте.


-- 1. Сила связи региона с ценой
SELECT
    CORR(price, region_avg_price)         AS r_region_price,
    CORR(LN(price), region_avg_log_price) AS r_region_log_price,
    COUNT(*)                              AS wines,
    COUNT(DISTINCT province)              AS regions
FROM (
    -- Для каждого вина: сколько вин в его регионе и средняя цена по региону
    SELECT
        province,
        price,
        COUNT(*)       OVER (PARTITION BY province) AS region_wines,
        AVG(price)     OVER (PARTITION BY province) AS region_avg_price,
        AVG(LN(price)) OVER (PARTITION BY province) AS region_avg_log_price
    FROM wines
    WHERE price IS NOT NULL
      AND price > 0
) wines_with_region_avg
WHERE region_wines >= 200;


-- 2. Топ-10 регионов по средней оценке
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
