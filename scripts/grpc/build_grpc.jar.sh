#!/bin/bash

# build soseedygrpc-all.jar
set -euxo pipefail

ANDROID_UNO="../../../android-uno/automation"

pushd $ANDROID_UNO

../gradle/gradlew -p dataseedingapi clean assemble
../gradle/gradlew -p soseedygrpc clean assemble fatJar

popd

cp $ANDROID_UNO/soseedygrpc/build/libs/soseedygrpc-all.jar .
