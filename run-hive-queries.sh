#!/usr/bin/env bash

this_script="`pwd`/`dirname $0`"

pushd ${this_script}/hive-scripts >/dev/null

chmod +x gen/udf_ip_to_location.py

hive -f 'queries.hql'
popd
