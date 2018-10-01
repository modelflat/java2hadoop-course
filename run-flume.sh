#!/usr/bin/env bash
flume-ng agent -f flume/flume.conf -n agent -Dflume.root.logger=INFO,console