-- Гипотеза: связь между ценой и рейтингом слабая
--
-- Цена сильно скошена вправо (медиана $25, максимум $3300), поэтому
-- корреляцию Пирсона считаем и на исходной цене, и на логарифме цены,
-- а для проверки — корреляцию Спирмена (Пирсон на рангах, к выбросам устойчив).
--
-- Результат (111 537 вин с ценой):
--   Пирсон, цена как есть     0.42
--   Пирсон, логарифм цены     0.62
--   Спирмен                   0.61
--
-- Вывод: гипотеза НЕ подтвердилась. Связь умеренно сильная и логарифмическая:
-- каждое удвоение цены добавляет в среднем 1.5–2 балла. Цена объясняет
-- около 38% разброса оценок (0.62² ≈ 0.38).
-- Ограничение: в датасете только вина с оценкой от 80 баллов (урезанный диапазон),
-- поэтому реальная связь может быть даже сильнее.


-- 1. Корреляции
SELECT
    CORR(price, points)     AS pearson_raw,
    CORR(LN(price), points) AS pearson_log_price,
    COUNT(*)                AS wines_with_price
FROM wines
WHERE price IS NOT NULL
  AND price > 0;


-- 2. Корреляция Спирмена: Пирсон, посчитанный на местах в рейтинге.
-- Для одинаковых значений берём средний ранг (как в классическом Спирмене):
-- RANK() даёт наименьшее место в группе, + (размер группы - 1) / 2 сдвигает к среднему.
SELECT
    CORR(rank_price, rank_points) AS spearman
FROM (
    SELECT
        RANK() OVER (ORDER BY price)
            + (COUNT(*) OVER (PARTITION BY price) - 1) / 2.0  AS rank_price,
        RANK() OVER (ORDER BY points)
            + (COUNT(*) OVER (PARTITION BY points) - 1) / 2.0 AS rank_points
    FROM wines
    WHERE price IS NOT NULL
      AND price > 0
) ranked;


-- 3. Средняя оценка по ценовым группам, где каждая следующая группа дороже в 2 раза.
-- Показывает форму связи: шаг в оценке на каждое удвоение цены примерно одинаковый.
SELECT
    POWER(2, FLOOR(LN(price) / LN(2)))::int         AS price_from_usd,
    POWER(2, FLOOR(LN(price) / LN(2)) + 1)::int - 1 AS price_to_usd,
    COUNT(*)                                         AS wines,
    ROUND(AVG(points)::numeric, 1)                   AS avg_points
FROM wines
WHERE price IS NOT NULL
  AND price > 0
GROUP BY 1, 2
ORDER BY 1;
