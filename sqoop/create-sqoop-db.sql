CREATE DATABASE IF NOT EXISTS sqoop;
USE sqoop;

DROP TABLE IF EXISTS hive_top10categories;
CREATE TABLE hive_top10categories (
    category VARCHAR(64), count_ INT
);

SELECT * FROM hive_top10categories;