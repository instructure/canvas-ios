#!/bin/bash

rm -rf tmp/ universal/

set -euo pipefail

if ! [ $1 ]; then
  echo "build_universal_framework.sh ./path/to/project/file SchemeName"
fi

if ! [ -x "$(command -v xcpretty)" ]; then
  gem install xcpretty
fi

SCHEME=$2
PROJECT=$1
TMP="$PWD/tmp"

# Build for device
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -sdk iphoneos \
  SYMROOT=$TMP \
  | xcpretty

# Build for simulator
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -sdk iphonesimulator \
  SYMROOT=$TMP \
  | xcpretty

DEVICE_FRAMEWORK="$TMP/Release-iphoneos/$SCHEME.framework/$SCHEME"
SIM_FRAMEWORK="$TMP/Release-iphonesimulator/$SCHEME.framework/$SCHEME"
UNI_DIR="$TMP/../universal"

mkdir "$UNI_DIR"

cp -RL "$TMP/Release-iphoneos/$SCHEME.framework" "$UNI_DIR"

UNI_FRAMEWORK="$UNI_DIR/$SCHEME.framework/$SCHEME"

# Create universal framework with correct dSYM
set -x
lipo -create \
  "$DEVICE_FRAMEWORK" \
  "$SIM_FRAMEWORK" \
  -output "$UNI_FRAMEWORK"
 dsymutil "$UNI_FRAMEWORK" \
  --out "$UNI_DIR/$SCHEME.framework.dSYM"