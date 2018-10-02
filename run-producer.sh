#!/usr/bin/env bash

size=${1:-1000}
slp=${2:-10}
count=${3:-0}

pushd `dirname $0`/events >/dev/null

while :
do
    ((count--<=0)) && break
    ./producer.bin $1 | nc localhost 44444 >/dev/null
    sleep $2
done

popd >/dev/null