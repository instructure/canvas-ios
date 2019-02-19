#!/bin/bash

set -euxo pipefail

DD="dd_tmp"
SCHEME="StudentUITests"
ZIP="ios_student_earlgrey.zip"

# Firebase test lab runs using -xctestrun
xcodebuild test-without-building \
  -xctestrun $DD/Build/Products/*.xctestrun \
  -derivedDataPath "$DD" \
  -destination 'id=ADD_YOUR_ID_HERE'

# get device identifier in Xcode -> Window -> Devices and Simulators
