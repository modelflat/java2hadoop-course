#!/usr/bin/env bash

hdfs dfs -put geodata.csv /

spark-submit --master local spark/spark-queries.py