#!/bin/zsh

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

for app in Student Teacher Parent; do
    appInfo=$allArchive/Products/Applications/$app.app/Info.plist
    appPath=Applications/$app.app
    bundleId=$(/usr/libexec/PlistBuddy $appInfo -c "Print CFBundleIdentifier")
    version=$(/usr/libexec/PlistBuddy $appInfo -c "Print CFBundleShortVersionString")

    appArchive=$archivePath/$app.xcarchive
    rm -rf $appArchive
    cp -r $allArchive $appArchive

    /usr/libexec/PlistBuddy $appArchive/Info.plist \
        -c "Add :ApplicationProperties dict" \
        -c "Add :ApplicationProperties:ApplicationPath string $appPath" \
        -c "Add :ApplicationProperties:CFBundleIdentifier string $bundleId" \
        -c "Add :ApplicationProperties:CFBundleShortVersionString string $version" \
        -c "Add :ApplicationProperties:CFBundleVersion string 1" \
        -c "Set :Name $app"
done
