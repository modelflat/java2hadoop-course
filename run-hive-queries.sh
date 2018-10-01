#!/usr/bin/env bash

this_script="`pwd`/`dirname $0`"

pushd ${this_script}/hive-scripts >/dev/null
hive -f 'queries.hql'
popd

echo "Hive queries are done! Now running Sqoop export"
./run-sqoop-export.sh