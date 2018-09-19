#!/usr/bin/env bash
./producer.bin $1 | nc localhost 44444 >/dev/null
