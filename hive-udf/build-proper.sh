#!/usr/bin/env bash

javac -classpath $(hadoop classpath):/usr/lib/hive/lib/* IPUtil.java 
jar cvf IPUtil.jar IPUtil.java
