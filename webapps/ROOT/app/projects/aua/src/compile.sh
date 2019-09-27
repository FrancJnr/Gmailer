#!/bin/bash

cd $(dirname $0)

export CLASSPATH=$CLASSPATH:../../../build/baraza.jar

javac ./com/dewcis/aua/*.java

