USE results;

-- validate top 10 categories
SELECT h.category, h.count_, s.count
FROM hive_top_categories as h LEFT OUTER JOIN spark_top_categories as s ON h.category=s.category
;

SELECT * from spark_top_products LIMIT 1;

-- validate top 10 products in categories
SELECT *
FROM hive_top_products as h LEFT OUTER JOIN spark_top_products AS s ON h.category=s.category AND h.name=s.name
ORDER BY s.category
;

-- validate top 10 countries
SELECT h.country, h.total AS "Hive result", s.total AS "Spark result"
FROM hive_top_countries as h LEFT OUTER JOIN spark_top_countries as s ON h.country=s.country
ORDER BY h.total DESC
;


