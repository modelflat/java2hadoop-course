#!/usr/bin/env bash

echo "! Make sure you have already populated HDFS with Flume Events"

./init-rdbms.sh

./run-hive-queries.sh

./run-sqoop-export.sh

./run-spark-queries.sh

./run-validation.sh

