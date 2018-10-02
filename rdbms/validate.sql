USE results;

-- validate top 10 categories
SELECT "Non-matching categories count:";
SELECT count(*) FROM (
  SELECT h.category, h.count_, s.count FROM hive_top_categories as h LEFT JOIN spark_top_categories as s ON h.category=s.category
  WHERE h.count_ != s.count
) AS t
;

-- validate top 10 products in categories
SELECT "";

-- validate top 10 countries
SELECT h.country, h.total, s.total FROM hive_top_countries as h LEFT JOIN spark_top_countries as s ON h.country=s.country WHERE h.total != s.total;