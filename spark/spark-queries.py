from pyspark import SparkContext
from pyspark.sql.session import SparkSession


spark = SparkSession(
    SparkContext()
)


from pyspark.sql.functions import col, lit, rank, udf, sum as spark_sum
from pyspark.sql.types import StringType, IntegerType
from pyspark.sql.window import Window
import numpy


df = spark.read\
    .format("csv")\
    .option("header", "false")\
    .schema("ts TIMESTAMP, ip STRING, category STRING, name STRING, price FLOAT")\
    .load("events.csv")

# top 10 categories
df\
    .groupBy("category")\
    .count()\
    .limit(10)\
    .show()


# top 10 products in categories
df\
    .groupBy("category", "name")\
    .count()\
    .orderBy(col("category").asc(),
             col("count").desc())\
    .withColumn("rank",
                rank().over(
                    Window
                        .partitionBy("category")
                        .orderBy(col("count").desc())
                ))\
    .where(col("rank") <= lit(10))\
    .show()

# top 10 countries by money spent
# part 1: setup UDF like in Hive
def make_udfs():
    def ip2num(ip):
        import ctypes
        a, b, c, d = map(int, ip.split("."))
        return ctypes.c_uint32((a << 24) | (b << 16) | (c << 8) | d).value

    def net2num(network):
        try:
            return ip2num(network.split("/")[0])
        except:
            return 0

    net2num_udf = udf(net2num, IntegerType())

    geodata = spark.read \
        .format("csv") \
        .option("header", "true") \
        .option("inferSchema", "true") \
        .load("geodata.csv") \
        .select(net2num_udf(col("network")).alias("network"), col("name").alias("country")) \
        .toPandas() # because it fits on one machine

    ips_broadcast, names_broadcast = \
        spark.sparkContext.broadcast(geodata.network.values.astype(numpy.uint32)), \
        spark.sparkContext.broadcast(geodata.country.values)

    def ip2country(ip):
        # do work analogous to Hive version. the only difference is that in spark we can make use of shared variables
        import bisect
        ip_num = ip2num(ip)
        idx = bisect.bisect_left(ips_broadcast.value, ip_num)
        return names_broadcast.value[idx - 1 if idx > 0 else 0]

    return udf(ip2country, StringType())


ip2country = make_udfs()

# part 2: write simple query
df\
    .select(col("price"), ip2country(col("ip")).alias("country"))\
    .cache()\
    .groupBy("country")\
    .agg(spark_sum(col("price")).alias("total"))\
    .orderBy(col("total").desc())\
    .limit(10)\
    .show()
