SET hive.cli.print.header = true;
SET hive.execution.engine = spark;

-- Register our udf (we will need it later)
ADD FILE /udf_ip_to_location.py;

-- Create table from flume events
CREATE EXTERNAL TABLE purchases(
        date_ STRING, ip STRING, category STRING, name STRING, price FLOAT
    )
    PARTITIONED BY (year_ INT, month_ INT, day_ INT)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
    STORED AS SEQUENCEFILE
    LOCATION '/flume/events/'
;

-- No need to add partitions manually due to our flume.conf :)

--ALTER TABLE purchases ADD
--    PARTITION (year_=2018, month_=1, day_=1) location '/flume/events/2018/01/01/'
--    PARTITION (year_=2018, month_=1, day_=2) location '/flume/events/2018/01/02/'
--    PARTITION (year_=2018, month_=1, day_=3) location '/flume/events/2018/01/03/'
--    PARTITION (year_=2018, month_=1, day_=4) location '/flume/events/2018/01/04/'
--    PARTITION (year_=2018, month_=1, day_=5) location '/flume/events/2018/01/05/'
--    PARTITION (year_=2018, month_=1, day_=6) location '/flume/events/2018/01/06/'
--    PARTITION (year_=2018, month_=1, day_=7) location '/flume/events/2018/01/07/'\
--;

-- Restore partitions
MSCK REPAIR TABLE purchases;


-- Top ten categories purchased
SELECT COUNT(*) AS count_purchased, category
FROM purchases
GROUP BY CATEGORY
ORDER BY count_purchased
LIMIT 10
;

-- Top ten (three, due to low variance in original dataset) products in each category
SELECT category, name
FROM (
    SELECT temp.name AS name, temp.category AS category,
        RANK() OVER (PARTITION BY temp.category ORDER BY temp.count_purchased DESC) AS rank_
    FROM (
        SELECT COUNT(*) AS count_purchased, name, category
        FROM purchases
        GROUP BY name, category
    ) AS temp
) AS t
WHERE rank_ <= 3
;

-- Top ten countries by money spent (with UDF)
SELECT SUM(price) as total, country
FROM purchases LEFT JOIN (
        SELECT TRANSFORM (ip) USING '/udf_ip_to_location.py' AS ip, country FROM purchases
    ) AS t
    ON t.ip = purchases.ip
GROUP BY country
ORDER BY total DESC
LIMIT 10
;

