from pyspark import SparkContext
from pyspark.sql import HiveContext, SQLContext, Row


sc = SparkContext()
sc.setLogLevel("WARN")

sqlContext = HiveContext(sc) # No Hive context == no ROW_NUMBER :(

from pyspark.sql.functions import col, lit, row_number, udf, sum as spark_sum
from pyspark.sql.types import StringType, IntegerType
from pyspark.sql.window import Window

# Compatibility with Spark 1.6
rdd = sc.sequenceFile("hdfs:///flume/events/**").map(
    lambda x: Row(*x[1].split(","))
)

df = sqlContext.createDataFrame(rdd, ["date", "ip", "category", "name", "price"]).cache()


def write_to_mysql(df, table):
    return df.write.jdbc(
        url="jdbc:mysql://localhost:3306/results",
        table=table,
        mode="overwrite",
        properties={
            "user": "root"
        }
    )


# top 10 categories
top_categories = df\
    .groupBy("category")\
    .count()\
    .orderBy(col("count").desc()) \
    .limit(10)
top_categories.show()

write_to_mysql(top_categories, "spark_top_categories")

# top 10 products in categories
top_products = df\
    .groupBy("category", "name")\
    .count()\
    .orderBy(col("category").asc(),
             col("count").desc())\
    .withColumn("rank",
                row_number().over(
                    Window
                        .partitionBy("category")
                        .orderBy(col("count").desc())
                ))\
    .where(col("rank") <= lit(10))
top_products.show()

write_to_mysql(top_products, "spark_top_products")

# top 10 countries by money spent
# part 1: setup UDF like in Hive
def make_udfs():
    import ctypes

    def ip2num(ip):
        a, b, c, d = map(int, ip.split("."))
        return ctypes.c_uint32((a << 24) | (b << 16) | (c << 8) | d).value

    def net2num(network):
        try:
            return ip2num(network.split("/")[0])
        except:
            return 0

    net2num_udf = udf(net2num, IntegerType())

    # geodata = spark.read \
    #     .format("csv") \
    #     .option("header", "true") \
    #     .option("inferSchema", "true") \
    #     .load("geodata.csv") \
    #     .select(net2num_udf(col("network")).alias("network"), col("name").alias("country")) \
    #     .toPandas() # because it fits on one machine

    geodata_rdd = sc.textFile("hdfs:///geodata.csv").map(lambda x: x.split(",", 1))

    # convert to DF to apply UDF
    geodata = sqlContext.createDataFrame(geodata_rdd, ["network", "name"]) \
        .select(net2num_udf(col("network")).alias("network"), col("name").alias("country")) \
        .cache()

    network_values = geodata.rdd.map(lambda r: ctypes.c_uint32(r["network"]).value).collect()
    country_values = geodata.rdd.map(lambda r: r["country"]).collect()

    ips_broadcast, names_broadcast = sc.broadcast(network_values), sc.broadcast(country_values)

    def ip2country(ip):
        # do work analogous to Hive version. the only difference is that in spark we can make use of shared variables
        import bisect
        ip_num = ip2num(ip)
        idx = bisect.bisect_left(ips_broadcast.value, ip_num)
        return names_broadcast.value[idx - 1 if idx > 0 else 0]

    return udf(ip2country, StringType())


ip2country = make_udfs()

# part 2: write simple query
top_countries = df \
    .select(col("price"), ip2country(col("ip")).alias("country"))\
    .cache()\
    .groupBy("country")\
    .agg(spark_sum(col("price")).alias("total"))\
    .orderBy(col("total").desc())\
    .limit(10)
top_countries.show()

write_to_mysql(top_countries, "spark_top_countries")


