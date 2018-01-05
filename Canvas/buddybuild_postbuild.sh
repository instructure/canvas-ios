#!/usr/bin/env bash

if [ "$SHOULD_UPLOAD_JS_SOURCE_MAPS" = "YES" ]; then
  version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "./Canvas/Info.plist")
  buildnumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "./Canvas/Info.plist")
  appversion="$version-$buildnumber"
  echo "sourcemap upload for $appversion"
  cd $BUDDYBUILD_WORKSPACE
  cd rn/Teacher
  echo "Generating sourcemap"
  react-native bundle --platform ios --dev false --entry-file index.ios.js --bundle-output main.jsbundle --sourcemap-output main.jsbundle.map
  echo "Uploading sourcemap"
  node ../rn/Teacher/node_modules/bugsnag-sourcemaps/cli.js upload --api-key ef596806053571e7315440f6d8d36bca --app-version ${appversion} --minified-file main.jsbundle --source-map main.jsbundle.map --minified-url main.jsbundle --upload-sources --overwrite
fi
