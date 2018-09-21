from pyspark import SparkContext
from pyspark.sql.session import SparkSession


spark = SparkSession(
    SparkContext()
)
sc = spark.sparkContext

from pyspark.sql.functions import col, lit, rank, udf, sum as spark_sum
from pyspark.sql.types import StringType, IntegerType
from pyspark.sql.window import Window
import numpy


rdd = sc.textFile("../events.csv").map(lambda x: x.split(",")).map(lambda x: {"ip": x[1], "category": x[2], "name": x[3], "price": float(x[4])})

# top 10 categories
rdd\
    .map(lambda x: (x["category"], 1))\
    .reduceByKey(lambda a, b: a + b)\
    .top(10)

# top 10 products in each categories
import heapq
rdd\
    .map(lambda x: ((x["category"], x["name"]), 1))\
    .reduceByKey(lambda a, b: a + b)\
    .map(lambda x: (x[0][0], (x[0][1], x[1])))\
    .groupByKey()\
    .mapValues(lambda x: heapq.nlargest(10, x, key=lambda x: x[1]))\
    .collect()

