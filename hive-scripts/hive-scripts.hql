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
--    PARTITION (year_=2018, month_=1, day_=7) location '/flume/events/2018/01/07/'
;

-- Restore partitions
MSCK REPAIR TABLE purchases;

SET hive.cli.print.header = true;

SELECT * FROM purchases LIMIT 10;