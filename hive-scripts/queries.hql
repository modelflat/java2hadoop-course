SET hive.cli.print.header = true;
SET hive.execution.engine = spark;

-- Register our udf (we will need it later)
ADD FILE gen/udf_ip_to_location.py;

-- Create table from flume events
CREATE EXTERNAL TABLE IF NOT EXISTS purchases(
        date_time STRING, ip STRING, category STRING, name STRING, price FLOAT
    )
    PARTITIONED BY (date_ STRING)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
    STORED AS SEQUENCEFILE
    LOCATION '/flume/events/'
;

-- Restore partitions
MSCK REPAIR TABLE purchases;

-- Top ten categories purchased
DROP TABLE IF EXISTS top_categories;
CREATE TABLE top_categories STORED AS ORC AS
SELECT COUNT(*) AS count_, category
FROM purchases
GROUP BY CATEGORY
ORDER BY count_ DESC
LIMIT 10
;
SELECT * FROM top_categories LIMIT 10;

-- Top ten products in each category
DROP TABLE IF EXISTS top_products;
CREATE TABLE top_products STORED AS ORC AS
SELECT * FROM
(
    SELECT temp.name AS name, temp.category AS category, temp.count_purchased as count_,
        ROW_NUMBER() OVER (PARTITION BY temp.category ORDER BY temp.count_purchased DESC) AS rank_
    FROM (
        SELECT COUNT(*) AS count_purchased, name, category
        FROM purchases
        GROUP BY name, category
    ) AS temp
) AS t
WHERE rank_ <= 10
;
SELECT * FROM top_products LIMIT 10;

-- Top ten countries by money spent (with UDF)
DROP TABLE IF EXISTS top_countries;
CREATE TABLE top_countries STORED AS ORC AS
SELECT SUM(price) as total, country
FROM purchases LEFT JOIN (
        SELECT TRANSFORM (ip) USING 'udf_ip_to_location.py' AS ip, country FROM purchases
    ) AS t
    ON t.ip = purchases.ip
GROUP BY country
ORDER BY total DESC
LIMIT 10
;
SELECT * FROM top_countries LIMIT 10;