USE results;

-- validate top 10 categories
SELECT h.category, h.count_ AS "Hive count", s.count AS "Spark count"
FROM hive_top_categories as h LEFT OUTER JOIN spark_top_categories as s ON h.category=s.category
;

-- validate top 10 products in categories
SELECT h.category, h.name, h.rank_ as "Hive rank", s.rank as "Spark Rank", h.count_ as "Hive Count", s.count as "Spark Count"
FROM hive_top_products as h LEFT OUTER JOIN spark_top_products AS s ON h.category=s.category AND h.name=s.name
;

-- validate top 10 countries
SELECT h.country, h.total AS "Hive result", s.total AS "Spark result"
FROM hive_top_countries as h LEFT OUTER JOIN spark_top_countries as s ON h.country=s.country
ORDER BY h.total DESC
;

-- validate all non-visually

SELECT count(*) AS "# of differences for query 1" FROM (
  SELECT h.category, h.count_, s.count
  FROM hive_top_categories as h LEFT OUTER JOIN spark_top_categories as s ON h.category=s.category
  WHERE h.count_ != s.count
) as t
;

SELECT count(*) AS "# of differences for query 2" FROM (
  SELECT h.category, h.name, h.rank_ as "Hive rank", s.rank as "Spark Rank", h.count_ as "Hive Count", s.count as "Spark Count"
  FROM hive_top_products as h LEFT OUTER JOIN spark_top_products AS s ON h.category=s.category AND h.name=s.name
  WHERE h.count_ != s.count
) as t
;

SELECT count(*) AS "# of differences for query 3" FROM (
  SELECT h.country, h.total AS "Hive result", s.total AS "Spark result"
  FROM hive_top_countries as h LEFT OUTER JOIN spark_top_countries as s ON h.country=s.country
  WHERE ROUND(h.total) != ROUND(s.total)
  ORDER BY h.total DESC
) as t
;