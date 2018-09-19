#!/usr/bin/env bash

while true
do
    ./producer.bin $1 | nc localhost 44444 >/dev/null
    sleep $2
done
