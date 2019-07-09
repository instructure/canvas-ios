#!/usr/bin/env bash
#
# This file is part of Canvas.
# Copyright (C) 2019-present  Instructure, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

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
  node ../Teacher/node_modules/bugsnag-sourcemaps/cli.js upload --api-key ef596806053571e7315440f6d8d36bca --app-version ${appversion} --minified-file main.jsbundle --source-map main.jsbundle.map --minified-url main.jsbundle --upload-sources --overwrite
fi
