#!/bin/bash

rm -rf xctestrun/

xcodebuild build-for-testing \
  -workspace AllTheThings.xcworkspace \
  -scheme "TeacherUITests" \
  -derivedDataPath xctestrun \
  -sdk iphoneos

cd xctestrun/Build/Products
ZIP=EarlGreyTeacher.zip
rm -rf "$ZIP"
# Needed to trick the FTL validation. Currently Debug-iphoneos is required.
# React native needs release builds for compiled javascript that doesn't depend on packager.
mkdir -p Debug-iphoneos
zip -r "$ZIP" *-iphoneos *.xctestrun
