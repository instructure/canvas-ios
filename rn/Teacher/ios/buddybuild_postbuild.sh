#!/usr/bin/env bash

if [ "$SHOULD_UPLOAD_JS_SOURCE_MAPS" = "YES" ]; then
  version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "./Teacher/Info.plist")
  buildnumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "./Teacher/Info.plist")
  appversion="$version-$buildnumber"
  echo "Uploading source maps for $appversion"
  node ../node_modules/bugsnag-sourcemaps/cli.js upload --api-key 2f55f80393ae9510379f412d8dbefb25 --app-version ${appversion} --minified-file main.jsbundle --source-map main.jsbundle.map --minified-url main.jsbundle --upload-sources --overwrite
fi