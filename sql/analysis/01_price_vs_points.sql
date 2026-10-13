-- Гипотеза: связь между ценой и рейтингом слабая
--
-- Результат (111 537 вин с ценой):
--   Пирсон, цена как есть   0.42
--   Пирсон, логарифм цены   0.62
--
-- Вывод: гипотеза не подтвердилась. Связь заметная, но не в долларах, а «в разах»:
-- дорогие вина в среднем оценены выше, и сильнее всего это видно на логарифме цены.

SELECT
    CORR(price, points)     AS pearson_raw,
    CORR(LN(price), points) AS pearson_log_price,
    COUNT(*)                AS wines_with_price
FROM wines
WHERE price IS NOT NULL
  AND price > 0;
