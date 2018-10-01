CREATE DATABASE IF NOT EXISTS results;
USE results;

DROP TABLE IF EXISTS hive_top_categories;
CREATE TABLE hive_top_categories (
    category VARCHAR(64), count_ INT
);
DROP TABLE IF EXISTS spark_top_categories;
CREATE TABLE spark_top_categories (
    category VARCHAR(64), count_ INT
);


DROP TABLE IF EXISTS hive_top_products;
CREATE TABLE hive_top_products (
    category VARCHAR(64), name VARCHAR(64), count_ INT
);
DROP TABLE IF EXISTS spark_top_products;
CREATE TABLE spark_top_products (
    category VARCHAR(64), name VARCHAR(64), count_ INT
);

DROP TABLE IF EXISTS hive_top_countries;
CREATE TABLE hive_top_countries (
    country VARCHAR(64), total FLOAT
);
DROP TABLE IF EXISTS spark_top_countries;
CREATE TABLE spark_top_countries (
    country VARCHAR(64), total FLOAT
);

SELECT "DONE";