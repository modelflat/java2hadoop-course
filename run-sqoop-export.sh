#!/usr/bin/env bash

sqoop export \
    --connect jdbc:mysql://localhost:3306/results \
    --username root \
    --table hive_top_categories \
    --hcatalog-table top_categories \
    --outdir /tmp

sqoop export \
    --connect jdbc:mysql://localhost:3306/results \
    --username root \
    --table hive_top_products \
    --hcatalog-table top_products \
    --outdir /tmp

sqoop export \
    --connect jdbc:mysql://localhost:3306/results \
    --username root \
    --table hive_top_countries \
    --hcatalog-table top_countries \
    --outdir /tmp
