CREATE EXTERNAL TABLE purchases(
    ip STRING, category STRING, name STRING, price FLOAT
)
PARTITIONED BY (date_ DATE)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
STORED AS TEXTFILE
LOCATION '/flume/events/';

alter table purchases add
    PARTITION (date_='2018-01-01') location '/flume/events/2018/01/01/'
    PARTITION (date_='2018-01-02') location '/flume/events/2018/01/02/'
    PARTITION (date_='2018-01-03') location '/flume/events/2018/01/03/'
    PARTITION (date_='2018-01-04') location '/flume/events/2018/01/04/'
    PARTITION (date_='2018-01-05') location '/flume/events/2018/01/05/'
    PARTITION (date_='2018-01-06') location '/flume/events/2018/01/06/'
    PARTITION (date_='2018-01-07') location '/flume/events/2018/01/07/';