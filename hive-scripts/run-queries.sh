#!/usr/bin/env bash

this_script="`pwd`/`dirname $0`"

pushd ${this_script}

#cat ${this_script} | hive
hive -f 'queries.hql'

popd