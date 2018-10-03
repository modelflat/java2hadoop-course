#!/usr/bin/env bash

hdfs dfs -put geodata.csv /

spark-submit --master yarn spark/spark-queries.py
