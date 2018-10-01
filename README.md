# Java engineer to Hadoop engineer

### Useful notes:

By default, mysql in cloudera/quickstart has slightly broken permissions and does
not allow to use `mysql`. To restart mysqld and fix this, run:

```bash
service mysqld stop && (mysqld_safe --skip-grant-tables &) && sleep 2 && echo
```

(`sleep 2 && echo` to automatically fix command line prompt after starting service)