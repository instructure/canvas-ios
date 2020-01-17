#!/bin/zsh
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

set -euo pipefail

script_dir="$(dirname "$0")"

cd "$script_dir/.."

usage() {
    echo "usage: find-flaky-pairs-of-tests.sh [--teacher] testClass.method"
}

TEST_SUITE=StudentUITests
while [[ "$#" -gt 0 && "$1" != "" ]]; do
    case $1 in
        --teacher )   TEST_SUITE=TeacherUITests
                      ;;
        -h | --help ) usage
                      exit 0
                      ;;
        * )           break
                      ;;
    esac
    shift
done

if [[ "$#" -ne 1 ]]; then
    usage
    exit 1
fi

export TEST_SCHEME=NightlyTests
export TARGET_TEST="$TEST_SUITE/${1:s#.#/#}"
export LOG_FILE="scripts/failing-test-pairs.txt"

echo "finding a flaky pair of tests conatining $TARGET_TEST"
echo "failed tests will be saved to \"$LOG_FILE\""

parallel --version >/dev/null || brew install parallel

xcb=(xcodebuild -workspace Canvas.xcworkspace -destination 'platform=iOS Simulator,name=iPhone 8' -scheme list-ui-tests)

$xcb build-for-testing 2>&1 | xcpretty
tests=(${(f)"$(
    $xcb test-without-building 2>/dev/null | \
    awk '$1 == "UI_TEST:" && $2 == "'$TEST_SUITE'" { print $2 "/" $3 "/" $4; }' | \
    tr -d '[]-'
)"})

echo
echo "=== Found tests in suite $TEST_SUITE ==="
echo $tests | tr ' ' $'\n'
echo "========================================"
echo

xcodebuild -workspace Canvas.xcworkspace -destination 'platform=iOS Simulator,name=iPhone 8' -scheme $TEST_SCHEME build-for-testing 2>&1 | xcpretty

jobs=1

parallel '
set -euo pipefail
xcrun simctl delete ip8-{} || true
xcrun simctl create ip8-{} "iPhone 8" com.apple.CoreSimulator.SimRuntime.iOS-13-2
xcrun simctl boot ip8-{}
' ::: $(seq $jobs)

rm -f "$LOG_FILE"

parallel --jobs $jobs '
set -euo pipefail
command=(xcodebuild \
        -workspace Canvas.xcworkspace \
        -destination "platform=iOS Simulator,name=ip8-"{%} \
        -scheme $TEST_SCHEME test-without-building \
        -parallel-testing-enabled NO \
        -only-testing:{} \
        -only-testing:$TARGET_TEST \
)
output=$($command 2>&1) || (printf "%s" "$output" >> $LOG_FILE)
printf "%s" "$output" | xcpretty --color
' ::: $tests

parallel 'xcrun simctl shutdown ip8-{} || true' ::: $(seq $jobs)

xcpretty --color < $LOG_FILE | less
