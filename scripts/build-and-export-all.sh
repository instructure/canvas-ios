#!/bin/zsh
#
# This file is part of Canvas.
# Copyright (C) 2020-present  Instructure, Inc.
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

# `xcodebuild archive` always builds from scratch, which is fairly redundant.
# Instead, we can archive a scheme that includes all 3 apps, then tweak the
# resulting generic xcarchive to be app-specific and suitible for ad-hoc export

set -euxo pipefail

archivePath=build/archives
allArchive=$archivePath/All.xcarchive
mkdir -p $archivePath tmp

xcodebuild \
    -workspace Canvas.xcworkspace \
    -scheme All \
    -configuration $BITRISE_CONFIGURATION \
    -archivePath $allArchive \
    -destination generic/platform=iOS \
    COMPILER_INDEX_STORE_ENABLE=NO \
    archive | xcpretty

exportOptionsPlist=tmp/exportOptions.plist
/usr/libexec/PlistBuddy $exportOptionsPlist \
    -c "Clear dict" \
    -c "Add :method string $BITRISE_EXPORT_METHOD" \
    -c "Add :iCloudContainerEnvironment string Production" \
    -c "Add :compileBitcode bool false"

apps=(Student Teacher Parent)
for app in $apps; do
    appInfo=$allArchive/Products/Applications/$app.app/Info.plist
    bundleId=$(/usr/libexec/PlistBuddy $appInfo -c "Print CFBundleIdentifier")
    version=$(/usr/libexec/PlistBuddy $appInfo -c "Print CFBundleShortVersionString")

    appArchive=$archivePath/$app.xcarchive
    rm -rf $appArchive
    cp -r $allArchive $appArchive

    # delete extra apps
    for otherApp in ${(@)apps:#$app}; do
        rm -rf $appArchive/Products/Applications/$otherApp.app
    done

    /usr/libexec/PlistBuddy $appArchive/Info.plist \
        -c "Add :ApplicationProperties dict" \
        -c "Add :ApplicationProperties:ApplicationPath string Applications/$app.app" \
        -c "Add :ApplicationProperties:CFBundleIdentifier string $bundleId" \
        -c "Add :ApplicationProperties:CFBundleShortVersionString string $version" \
        -c "Add :ApplicationProperties:CFBundleVersion string 1" \
        -c "Set :Name $app"
done
