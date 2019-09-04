#!/bin/zsh

set -eo pipefail

cd ..

export target_test=StudentDiscussionEditTests/testCreateDiscussionWithAttachment

echo "finding a flaky pair of tests conatining $target_test... failed tests will be saved to fail.txt"

parallel --version >/dev/null || brew install parallel

XCB=(xcodebuild -workspace Canvas.xcworkspace -destination 'platform=iOS Simulator,name=iPhone 8' -scheme list-student-ui-tests)

$XCB build-for-testing 2>&1 | xcpretty
tests=(${(f)"$($XCB test-without-building 2>/dev/null | awk '/^UI_TEST:/ { print $2 "/" $3; }' | tr -d '[]-')"})

xcodebuild -workspace Canvas.xcworkspace -destination 'platform=iOS Simulator,name=iPhone 8' -scheme CITests build-for-testing 2>&1 | xcpretty

JOBS=6

parallel '
xcrun simctl delete ip8-{} || true
xcrun simctl create ip8-{} "iPhone 8" com.apple.CoreSimulator.SimRuntime.iOS-12-4
xcrun simctl boot ip8-{}
' ::: $(seq $JOBS)

rm -f fail.txt

parallel --jobs $JOBS '
set -o pipefail
PRETTY=$(xcodebuild \
        -workspace Canvas.xcworkspace \
        -destination "platform=iOS Simulator,name=ip8-"{%} \
        -scheme CITests test-without-building \
        -parallel-testing-enabled NO \
        -only-testing:StudentUITests/{} \
        -only-testing:StudentUITests/$target_test 2>&1 \
        | xcpretty --color \
) || (printf "%s\n" "$PRETTY" >> fail.txt)
printf "%s\n" "$PRETTY"
' ::: $tests

parallel 'xcrun simctl shutdown ip8-{} || true' ::: $(seq $JOBS)

cat fail.txt
