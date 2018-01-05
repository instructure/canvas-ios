#!/usr/bin/env bash

if [ "$SHOULD_UPLOAD_JS_SOURCE_MAPS" = "YES" ]; then
  cd $BUDDYBUILD_WORKSPACE
  cd rn/Teacher
  version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "./ios/Teacher/Info.plist")
  buildnumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "./ios/Teacher/Info.plist")
  appversion="$version-$buildnumber"
  echo "sourcemap upload for $appversion"
  echo "Generating sourcemap"
  react-native bundle --platform ios --dev false --entry-file index.ios.js --bundle-output main.jsbundle --sourcemap-output main.jsbundle.map
  echo "Uploading sourcemap for $appversion"
  node node_modules/bugsnag-sourcemaps/cli.js upload --api-key 2f55f80393ae9510379f412d8dbefb25 --app-version ${appversion} --minified-file main.jsbundle --source-map main.jsbundle.map --minified-url main.jsbundle --upload-sources --overwrite
fi
