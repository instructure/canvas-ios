#!/bin/bash

set -euxo pipefail

DD="dd_tmp"
SCHEME="Student"
ZIP="ios_student_earlgrey.zip"

rm -rf "$DD"

xcodebuild build-for-testing \
  -workspace ../../Canvas.xcworkspace \
  -scheme "$SCHEME" \
  -derivedDataPath "$DD" \
  -sdk iphoneos

pushd "$DD/Build/Products"
zip -r "$ZIP" *-iphoneos *.xctestrun
popd
mv "$DD/Build/Products/$ZIP" .
