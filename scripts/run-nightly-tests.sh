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

function banner() (
    set +x
    local greenbold=$(export TERM=xterm-color; tput bold; tput setaf 2)
    printf "%s" $greenbold; echo " $@ " | tr -c $'\n' '='
    printf "%s" $greenbold; echo " $@ "
    printf "%s" $greenbold; echo " $@ " | tr -c $'\n' '='
    TERM=xterm-color tput sgr0
)

destination_flag=(-destination 'platform=iOS Simulator,name=iPhone 8')

banner "Building NightlyTests"

NSUnbufferedIO=YES xcodebuild -workspace Canvas.xcworkspace -scheme NightlyTests $destination_flag build-for-testing 2>&1 | xcpretty --color

BUILD_DIR=$(xcodebuild -workspace Canvas.xcworkspace -scheme NightlyTests -showBuildSettings build-for-testing -json |
                jq -r '.[] | select(.target == "CoreTests").buildSettings.BUILD_DIR')
base_xctestrun=($BUILD_DIR/NightlyTests_NightlyTests_*.xctestrun)
xctestrun=$base_xctestrun.script_run
cp $base_xctestrun $xctestrun
config_name=$(/usr/libexec/PlistBuddy $base_xctestrun -c "print :TestConfigurations:0:Name")

# usage: setEnv testrun.xctestrun VAR value
function setEnv {
    local i name
    for (( i = 0; ; i++ )); do
        name=$(/usr/libexec/PlistBuddy $1 -c "print :TestConfigurations:0:TestTargets:$i:BlueprintName" 2>/dev/null) || break
        echo "Setting $2=$3 in $1 $name"
        /usr/libexec/PlistBuddy $1 -c "add :TestConfigurations:0:TestTargets:$i:EnvironmentVariables:$2 string $3" || true
    done
    if [[ i -eq 0 ]]; then
        echo "failed to set any environment variables!"
        exit 1
    fi
}

try=0
all_passing_tests=()
tests_passed_this_run=()
tests_failed_this_run=()
total_failures=0
results_directory=nightly-xcresults
rm -rf $results_directory
mkdir -p $results_directory

function getTestResults {
    local result_path=$results_directory/$try.xcresult
    local test_result_id=($(xcrun xcresulttool get --format json --path $result_path |
                                 jq -r '.actions._values[].actionResult.testsRef.id._value'))
    local all_results_path=$results_directory/$try.json
    xcrun xcresulttool get --format json --path $result_path --id $test_result_id |
        jq '[.summaries._values[].testableSummaries._values[] |
                 .name._value as $bundleName |
                 .tests?._values[]? |
                 recurse(.subtests?._values[]?) |
                 select(._type._name == "ActionTestMetadata") |
                 ($bundleName + "/" + .identifier._value | rtrimstr("()")) as $testId |
                 {"status": .testStatus._value, "id": $testId}]' \
                     > $all_results_path || return $?
    tests_passed_this_run=($(jq -r '.[] | select(.status == "Success").id' $all_results_path)) || return $?
    tests_failed_this_run=($(jq -r '.[] | select(.status == "Failure").id' $all_results_path)) || return $?

    if (( ${#tests_passed_this_run} + ${#tests_failed_this_run} == 0 )); then
        echo "Couldn't find any test results... probably a bug!"
        jq -C . <$all_results_path
        exit 1
    fi

    all_passing_tests+=($tests_passed_this_run)
}

# usage: doTest testrun.xctestrun
function doTest {
    /usr/libexec/PlistBuddy $xctestrun -c "set :TestConfigurations:0:Name \"$config_name (retry $try)\""

    banner "Running $(basename $xctestrun) (retry $try)"
    local result_path=$results_directory/$try.xcresult
    local ret=0

    local formatter=(xcpretty --color)

    local flags=($destination_flag)
    flags+=(-resultBundlePath $result_path)
    flags+=(-xctestrun $xctestrun)
    if (( try < 1 )); then
        flags+=(-parallel-testing-enabled YES -parallel-testing-worker-count 3)
        formatter=(env NSUnbufferedIO=YES xcbeautify)
    fi
    for skip in $all_passing_tests; do
        flags+=(-skip-testing:$skip)
    done
    NSUnbufferedIO=YES xcodebuild test-without-building $flags 2>&1 | $formatter ||
        ret=$?

    getTestResults || return $?
    banner "${#tests_passed_this_run} tests passed"
    banner "${#tests_failed_this_run} tests failed"
    print ${(F)tests_failed_this_run}
    (( total_failures += ${#tests_failed_this_run} ))
    return $ret
}

function retry {
    (( try += 1 ))
    banner "Retrying"

    setEnv $xctestrun CANVAS_TEST_IS_RETRY YES || return $?
    doTest || return $?
}

xcrun simctl boot 'iPhone 8' || true
open -a /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app

ret=0
doTest $base_xctestrun ||
    retry ||
    retry ||
    retry ||
    retry ||
    ret=$?

if [[ $ret -eq 0 ]]; then
    if [[ $try -eq 0 ]]; then
        banner "\U1F389 All tests passed ON THE FIRST TRY! \U1F389"
    else
        banner "All tests passed after $try retries! ($total_failures flaky failures)"
    fi
else
    banner "${#tests_failed_this_run} Tests still failing after $try retries"
    echo "failing tests:"
    print ${(F)tests_failed_this_run}
fi

results=($results_directory/*.xcresult)
merged_result_path=$results_directory/merged.xcresult
if [[ ${#results} -gt 1 ]]; then
    xcrun xcresulttool merge $results --output-path $merged_result_path
else
    cp -r $results $merged_result_path
fi

exit $ret
