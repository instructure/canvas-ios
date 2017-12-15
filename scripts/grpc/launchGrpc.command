#!/usr/bin/env bash

echo -en "\033]0;SoSeedy gRPC\a"
clear

DIR=$(dirname "$0")
JAR="soseedygrpc-all.jar"
/usr/bin/env java -jar "$DIR/$JAR"
