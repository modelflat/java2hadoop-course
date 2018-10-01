#!/usr/bin/env bash

../hive-scripts/run-queries.sh

sqoop export \
    --connect jdbc:mysql://localhost:3306/sqoop \
    --username root
    --table hive_top10categories
    --hcatalog-table top10categories