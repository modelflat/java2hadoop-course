#!/usr/bin/env bash

mysql --user=root -s < create-sqoop-db.sql

../hive-scripts/run-queries.sh

sqoop export \
    --connect jdbc:mysql://localhost:3306/sqoop \
    --username root
    --table hive_top10categories
    --hcatalog-table top10categories