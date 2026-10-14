-- Гипотеза: связь между ценой и рейтингом слабая
--
-- Запрос 1 — насколько сильная связь (111 537 вин с ценой):
--   Пирсон, цена как есть   0.42
--   Пирсон, логарифм цены   0.62
--
-- Запрос 2 — насколько дорогие вина оценены выше:
--   Цена        Средняя оценка   Доля вин с оценкой 90+
--   до $15      85.6              3.4%
--   $15–30      87.6             23.8%
--   $30–60      89.6             55.8%
--   $60–100     91.2             77.9%
--   $100+       92.7             89.0%
--
-- Вывод: гипотеза о слабой связи не подтвердилась — связь умеренная (r = 0.62 на логарифме цены).
-- Среди вин до $15 оценку 90+ получают 3.4%, среди вин за $100+ — 89%.
-- При этом цена объясняет только около 38% разброса оценок (0.62² ≈ 0.38):
-- остальное зависит от других факторов, и хорошие недорогие вина встречаются часто.


-- 1. Корреляция Пирсона: на цене как есть и на логарифме цены
SELECT
    CORR(price, points)     AS pearson_raw,
    CORR(LN(price), points) AS pearson_log_price,
    COUNT(*)                AS wines_with_price
FROM wines
WHERE price IS NOT NULL
  AND price > 0;


-- 2. Оценки по ценовым группам: насколько дорогие вина оценены выше
SELECT
    CASE
        WHEN price < 15  THEN '1. до $15'
        WHEN price < 30  THEN '2. $15–30'
        WHEN price < 60  THEN '3. $30–60'
        WHEN price < 100 THEN '4. $60–100'
        ELSE                  '5. $100+'
    END                                                             AS price_group,
    COUNT(*)                                                        AS wines,
    ROUND(AVG(points)::numeric, 1)                                  AS avg_points,
    ROUND(100.0 * AVG(CASE WHEN points >= 90 THEN 1 ELSE 0 END), 1) AS pct_90_plus
FROM wines
WHERE price IS NOT NULL
GROUP BY price_group
ORDER BY price_group;
