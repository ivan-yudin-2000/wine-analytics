-- Гипотеза: самые известные сорта (Pinot Noir, Cabernet Sauvignon, Chardonnay) — в топе по оценкам
--
-- Берём только сорта, где 200+ вин: у сорта с 3 винами средняя оценка случайна.
-- Таких сортов 59, в них 91% всех вин.
--
-- Запрос 1 — топ-10 сортов по средней оценке:
--   Сорт                 Вин     Средняя оценка   Средняя цена
--   Sangiovese Grosso      696   90.6             $65
--   Nebbiolo             2 607   90.3             $66
--   Blaufränkisch          213   90.1             $33
--   Grüner Veltliner     1 201   90.0             $28
--   Port                   628   89.8             $66
--   Champagne Blend      1 308   89.7             $71
--   Riesling             4 772   89.5             $33
--   Pinot Noir          12 275   89.4             $48
--   Syrah                3 828   89.3             $39
--   Aglianico              339   89.3             $39
--
-- Запрос 2 — три известных сорта:
--   Pinot Noir          12 275   89.4             $48
--   Cabernet Sauvignon   8 838   88.6             $48
--   Chardonnay          10 865   88.3             $35
--
-- Вывод: гипотеза подтвердилась только частично. Из трёх известных сортов в топ-10 попал
-- только Pinot Noir (8-е место, 89.4). Cabernet Sauvignon (88.6) и Chardonnay (88.3)
-- в топ-10 не вошли: у 10-го места средняя оценка 89.3.
-- Высокие оценки бывают и у недорогих сортов: Grüner Veltliner ($28), Blaufränkisch и Riesling ($33)
-- в топе, хотя они дешевле Pinot Noir и Cabernet Sauvignon ($48).
--
-- Ограничения:
-- - в колонке variety кроме сортов есть купажи и стили (Champagne Blend, Port, Red Blend);
-- - один сорт иногда записан под разными названиями (Syrah и Shiraz, Grenache и Garnacha,
--   Pinot Gris и Pinot Grigio) и считается как два разных.


-- 1. Топ-10 сортов по средней оценке
SELECT
    variety,
    COUNT(*)                       AS wines,
    ROUND(AVG(points)::numeric, 1) AS avg_points,
    ROUND(AVG(price)::numeric, 0)  AS avg_price
FROM wines
GROUP BY variety
HAVING COUNT(*) >= 200
ORDER BY AVG(points) DESC
LIMIT 10;


-- 2. Средняя оценка трёх известных сортов
SELECT
    variety,
    COUNT(*)                       AS wines,
    ROUND(AVG(points)::numeric, 1) AS avg_points,
    ROUND(AVG(price)::numeric, 0)  AS avg_price
FROM wines
WHERE variety IN ('Pinot Noir', 'Cabernet Sauvignon', 'Chardonnay')
GROUP BY variety
ORDER BY AVG(points) DESC;
