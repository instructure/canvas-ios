#!/usr/bin/env bash

TEACHER_APP_ID=58b0b2116096900100863eb8

if [ "$BUDDYBUILD_BRANCH" = "develop" ] && [ "$BUDDYBUILD_APP_ID" = "$TEACHER_APP_ID" ]; then
    aws s3 sync ../coverage s3://inseng-code-coverage/ios-teacher/coverage
fi

if [ "$SHOULD_UPLOAD_JS_SOURCE_MAPS" = "YES" ]; then
    version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "./Teacher/Info.plist")
    echo "Uploading source maps for version $version"
    node ../node_modules/bugsnag-sourcemaps/cli.js upload --api-key 671fc47c3812aa323469568f33244e2c --app-version ${version} --minified-file main.jsbundle --source-map main.jsbundle.map --minified-url main.jsbundle --upload-sources --overwrite
fi
