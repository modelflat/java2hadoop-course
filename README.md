# Java engineer to Hadoop engineer

### Useful notes:

* MySql permissions

By default, mysql in cloudera/quickstart has slightly broken permissions and does
not allow to use `mysql`. To restart mysqld and fix this, run:

```bash
service mysqld stop && (mysqld_safe --skip-grant-tables &) && sleep 2 && echo
```

(`sleep 2 && echo` to automatically fix command line prompt after starting service)

This fix is applied in `./start-cloudera.sh`.

* Old PySpark

cloudera/quickstart has Spark 1.6 installed, and this also may be a problem (at least for a PySpark user).
For example, attempts to export data into mysql using JDBC may fail with obscure error:
```
java.lang.RuntimeException: com.mysql.jdbc.Driver does not allow create table as select.
    ... long traceback here ...
```
 
This happens when you use the following snippet:

```
df.write.format("jdbc").options(...).mode(...).save();
```

but it works completely fine when using it another way:

```
df.write.jdbc( ... all the options here ...);
```

* Hive/MapReduce stalling

When running cloudera/quickstart image locally on Mac OS, at certain point you may
encounter impossibility to run Hive/Spark/MapReduce jobs at all. For example, 
Hive will hang on simple `select count(*) from table_name;`. It will print something
like this: 

```
Starting Job = ...
Kill Command = /usr/lib/hadoop/bin/hadoop job  -kill job_1538485947126_0003
```

but no job will start whatsoever. Logs 
(when hive CLI is started with `hive --hiveconf hive.root.logger=INFO,console,DEBUG`)
will show an ambiguous error (smt like `[ERROR] mr.ExecDriver: yarn`).

The cause of this is unknown, but `docker system prune` fixed this for me.
