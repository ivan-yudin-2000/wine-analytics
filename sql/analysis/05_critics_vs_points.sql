-- Гипотеза: разные критики оценивают с разной строгостью
--
-- Критик = колонка taster_name. Имя критика указано у 95 012 отзывов из 119 928,
-- отзывы без имени не учитываем. Берём только критиков с 200+ отзывами (16 из 19).
--
-- Сложность: каждый критик в основном оценивает вина своих стран (Roger Voss — Франция,
-- Kerin O’Keefe — Италия, Michael Schachner — Испания и Южная Америка). Поэтому разница
-- в средних может объясняться тем, какие вина достались критику, а не его строгостью.
-- Чтобы сравнение было честнее, во втором запросе сравниваем критиков внутри одного региона:
-- берём регионы, где минимум два критика оценили по 200+ вин.
--
-- Запрос 1 — средняя оценка у каждого критика:
--   Критик               Отзывов   Средняя оценка   Средняя цена
--   Anne Krebiehl MW       3 282   90.6             $32
--   Matt Kettmann          5 730   90.1             $39
--   Virginie Boone         8 708   89.2             $47
--   ...
--   Michael Schachner     14 039   86.9             $25
--   Susan Kostrzewa        1 018   86.6             $23
--   Alexander Peartree       383   85.8             $29
--
-- Запрос 2 — критики внутри одного региона:
--   Регион        Критик               Отзывов   Средняя оценка   Средняя цена
--   Alsace        Anne Krebiehl MW       1 257   90.5             $32
--   Alsace        Roger Voss               868   87.9             $28
--   Burgenland    Anne Krebiehl MW         344   90.2             $29
--   Burgenland    Roger Voss               263   88.9             $32
--   California    Matt Kettmann          5 728   90.1             $39
--   California    Virginie Boone         8 703   89.2             $47
--   California    Jim Gordon             3 762   88.6             $27
--   Washington    Paul Gregutt           3 874   89.1             $30
--   Washington    Sean P. Sullivan       4 079   88.9             $35
--
-- Вывод: гипотеза подтвердилась. Средние оценки у критиков различаются почти на 5 баллов
-- (90.6 у самого щедрого против 85.8 у самого строгого), но часть этой разницы объясняется
-- разными винами. Внутри одного региона разница меньше, но остаётся: в Эльзасе
-- Anne Krebiehl MW ставит в среднем на 2.6 балла больше, чем Roger Voss, при похожих ценах,
-- а в Бургенланде — на 1.3 балла больше, хотя у Roger Voss вина даже дороже.
-- При этом не все критики различаются: в Вашингтоне Paul Gregutt и Sean P. Sullivan
-- оценивают почти одинаково (89.1 и 88.9).
--
-- Ограничения:
-- - у 21% отзывов имя критика не указано;
-- - даже внутри одного региона критики пробуют не одни и те же вина
--   (разные винодельни и годы), поэтому сравнение честнее, но не идеальное.


-- 1. Средняя оценка у каждого критика
SELECT
    taster_name,
    COUNT(*)                       AS wines,
    ROUND(AVG(points)::numeric, 1) AS avg_points,
    ROUND(AVG(price)::numeric, 0)  AS avg_price
FROM wines
WHERE taster_name IS NOT NULL
GROUP BY taster_name
HAVING COUNT(*) >= 200
ORDER BY AVG(points) DESC;


-- 2. Критики внутри одного региона
SELECT
    province,
    taster_name,
    COUNT(*)                       AS wines,
    ROUND(AVG(points)::numeric, 1) AS avg_points,
    ROUND(AVG(price)::numeric, 0)  AS avg_price
FROM wines
WHERE province IN ('Alsace', 'Burgenland', 'California', 'Washington')
  AND taster_name IS NOT NULL
GROUP BY province, taster_name
HAVING COUNT(*) >= 200
ORDER BY province, AVG(points) DESC;
