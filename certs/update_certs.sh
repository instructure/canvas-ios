#!/usr/bin/env bash

set -euxo pipefail

SOURCE="../../android-uno/private-data/soseedygrpc"
TARGET="."
cp "$SOURCE/ca.crt" $TARGET
cp "$SOURCE/client.crt" $TARGET
cp "$SOURCE/client.pem" $TARGET
