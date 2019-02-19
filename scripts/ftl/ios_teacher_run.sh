#!/bin/bash

set -euxo pipefail

DD="dd_ios_teacher_ftl"
SCHEME="TeacherUITests"
ZIP="ios_teacher_earlgrey.zip"

xcodebuild test-without-building \
  -xctestrun $DD/Build/Products/*.xctestrun \
  -derivedDataPath "$DD" \
  -destination 'id=ADD_YOUR_ID_HERE'

# get device identifier in Xcode -> Window -> Devices and Simulators
