CREATE DATABASE IF NOT EXISTS results;
USE results;

DROP TABLE IF EXISTS hive_top_categories;
CREATE TABLE hive_top_categories (
    category VARCHAR(64) NOT NULL, count_ INT,
    PRIMARY KEY (category)
);
DROP TABLE IF EXISTS spark_top_categories;
CREATE TABLE spark_top_categories (
    category VARCHAR(64) NOT NULL, count_ INT,
    PRIMARY KEY (category)
);

DROP TABLE IF EXISTS hive_top_products;
CREATE TABLE hive_top_products (
    category VARCHAR(64) NOT NULL, name VARCHAR(64) NOT NULL, count_ INT,
    PRIMARY KEY (category, name)
);
DROP TABLE IF EXISTS spark_top_products;
CREATE TABLE spark_top_products (
    category VARCHAR(64) NOT NULL, name VARCHAR(64) NOT NULL, count_ INT,
    PRIMARY KEY (category, name)
);

DROP TABLE IF EXISTS hive_top_countries;
CREATE TABLE hive_top_countries (
    country VARCHAR(64) NOT NULL, total FLOAT,
    PRIMARY KEY (country)
);
DROP TABLE IF EXISTS spark_top_countries;
CREATE TABLE spark_top_countries (
    country VARCHAR(64) NOT NULL, total FLOAT,
    PRIMARY KEY (country)
);

SELECT "DONE";