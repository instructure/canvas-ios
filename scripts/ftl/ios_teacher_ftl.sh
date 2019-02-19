#!/bin/bash

set -euxo pipefail

DD="dd_ios_teacher_ftl"
SCHEME="TeacherUITests"
ZIP="ios_teacher_earlgrey.zip"

rm -rf "$DD"

pushd ../../rn/Teacher
yarn build
popd

xcodebuild build-for-testing \
  -workspace ../../AllTheThings.xcworkspace \
  -scheme "$SCHEME" \
  -derivedDataPath "$DD" \
  -sdk iphoneos

pushd "$DD/Build/Products"
zip -r "$ZIP" *-iphoneos *.xctestrun
popd
mv "$DD/Build/Products/$ZIP" .
