#!/usr/bin/env bash
rm -f ./flank.ios.xml
set -ex

# paid project: delta-essence-114723
# free project: bootstraponline-awesome-sauce
cat << 'EOF' > ./flank.ios.yml
gcloud:
  project: delta-essence-114723
  xcode-version: 10.0
  test: ./ios_student_earlgrey.zip
  xctestrun-file: ./dd_tmp/Build/Products/StudentUITests_iphoneos12.0-arm64e.xctestrun
  results-bucket: ios_student
  performance-metrics: false
  record-video: true
  timeout: 30m
  device:
  - model: iphone8
    version: 12.0
    orientation: portrait
    locale: en_US

flank:
  testShards: 1
  testRuns: 1
EOF

flank firebase test ios run