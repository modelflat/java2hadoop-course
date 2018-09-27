CREATE EXTERNAL TABLE geodata (
    network STRING, country STRING, code STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
STORED AS TEXTFILE
LOCATION '/geo'
TBLPROPERTIES('skip.header.line.count'='1')
;