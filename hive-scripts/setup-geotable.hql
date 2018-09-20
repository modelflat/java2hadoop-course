CREATE EXTERNAL TABLE geodata (
    network STRING, country STRING, code STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
STORED AS TEXTFILE
LOCATION '/geo'
TBLPROPERTIES('skip.header.line.count'='1')
;

CREATE EXTERNAL TABLE geodata (
    network STRING, country STRING, code STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
STORED AS TEXTFILE
LOCATION 's3://aelistratov-lpfinal-project/geodata/'
TBLPROPERTIES('skip.header.line.count'='1')
;