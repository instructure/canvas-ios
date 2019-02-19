#!/bin/bash

set -euxo pipefail

if ! [ -x "$(command -v xcpretty)" ]; then
  gem install xcpretty
fi

DD="dd_tmp"
SCHEME="StudentUITests"
ZIP="ios_student_earlgrey.zip"

rm -rf "$DD"

xcodebuild build-for-testing \
  -workspace ../../Canvas.xcworkspace \
  -scheme "$SCHEME" \
  -derivedDataPath "$DD" \
  -sdk iphoneos \
  | xcpretty

pushd "$DD/Build/Products"
zip -r "$ZIP" *-iphoneos *.xctestrun
popd
mv "$DD/Build/Products/$ZIP" .
