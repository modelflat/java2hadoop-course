#!/usr/bin/env bash


hdfs dfs -mkdir -p /geo
hdfs dfs -put $1 /geo/
hdfs dfs -ls /geo
