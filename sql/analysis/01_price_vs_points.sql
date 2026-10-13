-- Гипотеза: связь между ценой и рейтингом слабая
--
-- Результат (111 537 вин с ценой):
--   Пирсон, цена как есть   0.42
--   Пирсон, логарифм цены   0.62
--
--   Средняя оценка по ценовым группам:
--   до $15      85.6
--   $15–30      87.6
--   $30–60      89.6
--   $60–100     91.2
--   $100+       92.7
--
-- Вывод: гипотеза не подтвердилась. Связь заметная, но не в долларах, а «в разах»:
-- дорогие вина в среднем оценены выше, и сильнее всего это видно на логарифме цены.
-- Разница между самыми дешёвыми и самыми дорогими винами — около 7 баллов в среднем.


-- 1. Корреляция Пирсона: на цене как есть и на логарифме цены
SELECT
    CORR(price, points)     AS pearson_raw,
    CORR(LN(price), points) AS pearson_log_price,
    COUNT(*)                AS wines_with_price
FROM wines
WHERE price IS NOT NULL
  AND price > 0;


-- 2. Средняя оценка по ценовым группам: насколько дорогие вина оценены выше
SELECT
    CASE
        WHEN price < 15  THEN '1. до $15'
        WHEN price < 30  THEN '2. $15–30'
        WHEN price < 60  THEN '3. $30–60'
        WHEN price < 100 THEN '4. $60–100'
        ELSE                  '5. $100+'
    END                            AS price_group,
    COUNT(*)                       AS wines,
    ROUND(AVG(points)::numeric, 1) AS avg_points
FROM wines
WHERE price IS NOT NULL
GROUP BY price_group
ORDER BY price_group;
