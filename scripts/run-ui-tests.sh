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

# needed to run this script:
# xcbeautify jq

# brew tap thii/xcbeautify https://github.com/thii/xcbeautify.git
# brew install xcbeautify jq

set -euo pipefail

function usage {
    echo "Runs a UI test suite, retrying failed ones."
    echo "usage:"
    echo "  ./scripts/run-ui-tests.sh --build"
    echo "  ./scripts/run-ui-tests.sh [--build] [--append-results] --all-tests"
    echo "  ./scripts/run-ui-tests.sh [--build] [--append-results] --only-testing <testId> ..."
    echo "  ./scripts/run-ui-tests.sh --help"
    echo
    echo "optional env variables:"
    echo '  SCHEME (default: "NightlyTests")'
    echo '  DEVICE_NAME (default: "iPhone 8")'
    exit $1
}

SCHEME=${SCHEME:-NightlyTests}
DEVICE_NAME=${DEVICE_NAME:-iPhone 8}

testrun_id=$(date +%s)

only_testing=()
needs_build=no
only_build=yes
celebration=yes
clobber_results=yes

[[ $# -gt 0 ]] || usage 1
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            usage 0
            ;;
        --build)
            shift
            needs_build=yes
            ;;
        --append-results)
            shift
            clobber_results=no
            ;;
        --all-tests)
            [[ $# -eq 1 ]] || usage 1
            only_build=no
            break
            ;;
        --only-testing)
            shift
            [[ $# -gt 0 ]] || usage 1
            only_testing+=($@)
            only_build=no
            celebration=no
            break
            ;;
        *)
            usage 1
            ;;
    esac
done

function banner() (
    set +x
    local greenbold=$(export TERM=xterm-color; tput bold; tput setaf 2)
    printf "%s" $greenbold; echo " $@ " | tr -c $'\n' '='
    printf "%s" $greenbold; echo " $@ "
    printf "%s" $greenbold; echo " $@ " | tr -c $'\n' '='
    TERM=xterm-color tput sgr0
)

mkdir -p tmp
export NSUnbufferedIO=YES

destination_flag=(-destination "platform=iOS Simulator,name=$DEVICE_NAME")

results_directory=ui-test-results
if [[ $clobber_results = yes ]]; then
    rm -rf $results_directory
fi
mkdir -p $results_directory

if [[ $needs_build = yes ]]; then
    banner "Building $SCHEME"
    xcodebuild -workspace Canvas.xcworkspace -scheme $SCHEME $destination_flag build-for-testing 2>&1 |
        tee -a ${BITRISE_DEPLOY_DIR-$results_directory}/build.log |
        xcbeautify --quiet
fi

if [[ $only_build = yes ]]; then
    exit 0
fi

BUILD_DIR=$(xcodebuild -workspace Canvas.xcworkspace -scheme $SCHEME -showBuildSettings $destination_flag build-for-testing -json |
                jq -r '.[0].buildSettings.BUILD_DIR')
base_xctestrun=($BUILD_DIR/${SCHEME}_*_iphonesimulator*.xctestrun)
xctestrun=$base_xctestrun.script_run
cp $base_xctestrun $xctestrun
config_name=$(/usr/libexec/PlistBuddy $base_xctestrun -c "print :TestConfigurations:0:Name")

# usage: setTestRunEnv testrun.xctestrun VAR value
# Not space-safe
function setTestRunEnv {
    local i name
    for (( i = 0; ; i++ )); do
        name=$(/usr/libexec/PlistBuddy $1 -c "print :TestConfigurations:0:TestTargets:$i:BlueprintName" 2>/dev/null) || break
        echo "Setting $2=$3 in $1 $name"
        /usr/libexec/PlistBuddy $1 -c "add :TestConfigurations:0:TestTargets:$i:EnvironmentVariables:$2 string $3" ||
        /usr/libexec/PlistBuddy $1 -c "set :TestConfigurations:0:TestTargets:$i:EnvironmentVariables:$2 $3"
    done
    if [[ i -eq 0 ]]; then
        echo "failed to set any environment variables!"
        return 1
    fi
}

try=0
all_passing_tests=()
tests_passed_this_run=()
tests_failed_this_run=()
total_failures=0

function mergeResults {
    merged_result_path=$results_directory/merged.xcresult
    if [[ -e $merged_result_path ]]; then
        mv $merged_result_path $results_directory/old-merged-$testrun_id.xcresult
    fi
    results=($results_directory/*.xcresult)
    if [[ ${#results} -gt 1 ]]; then
        xcrun xcresulttool merge $results --output-path $merged_result_path
        rm -rf $results
    else
        mv $results $merged_result_path
    fi
}

function getTestResults {
    tests_passed_this_run=0
    tests_failed_this_run=0

    local result_path=$results_directory/$try.xcresult
    if [[ ! -d $result_path ]]; then
        echo "Couldn't find test results!"
        touch $results_directory/final-failed.txt
        envman add --key TESTS_FAILED --value yes
        exit 1
    fi
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
        echo "Couldn't find any test results"
        crash_logs=($result_path/Staging/**/*.crash(N))
        banner "found ${#crash_logs} crash logs"
        for crash_log in $crash_logs; do
            banner $crash_log
            cat $crash_log
        done
    fi

    banner "${#tests_passed_this_run} tests passed"
    banner "${#tests_failed_this_run} tests failed"
    print ${(F)tests_failed_this_run}
    (( total_failures += ${#tests_failed_this_run} ))
    all_passing_tests+=($tests_passed_this_run)
}

# usage: doTest testrun.xctestrun
function doTest {
    /usr/libexec/PlistBuddy $xctestrun -c "set :TestConfigurations:0:Name \"$config_name (retry $try)\""

    banner "Running $(basename $xctestrun) (retry $try)"
    local result_path=$results_directory/$try.xcresult

    local flags=($destination_flag)
    flags+=(-resultBundlePath $result_path)
    flags+=(-xctestrun $xctestrun)

    if false; then
        flags+=(-parallel-testing-enabled YES -parallel-testing-worker-count 3)
    fi
    for skip in $all_passing_tests; do
        flags+=(-skip-testing:$skip)
    done
    for test in $only_testing; do
        flags+=(-only-testing:$test)
    done

    # Do this the long way to make sure we get the correct exit code
    pipe_file=tmp/formatter-fifo
    rm -rf $pipe_file
    mkfifo $pipe_file

    < $pipe_file tee -a ${BITRISE_DEPLOY_DIR-$results_directory}/test-run-xcodebuild.log | xcbeautify &
    local formatter_pid=$!
    local ret=0
    xcodebuild test-without-building $flags > $pipe_file 2> $pipe_file || ret=$?
    wait $formatter_pid
    rm -rf $pipe_file

    getTestResults
    return $ret
}

function retry {
    (( try += 1 ))
    banner "Retrying"

    setTestRunEnv $xctestrun CANVAS_TEST_IS_RETRY YES

    local video_pid
    if [[ ${record_video:-NO} = YES ]]; then
        video_file=${BITRISE_DEPLOY_DIR-$results_directory}/$testrun_id-$try.mp4
        echo "recording video to $video_file"
        xcrun simctl io booted recordVideo $video_file &
        video_pid=$!
    fi
    local ret=0
    doTest || ret=$?
    if [[ -n $video_pid ]]; then
        kill -INT $video_pid || true
        wait $video_pid
    fi
    return $ret
}

xcrun simctl boot $DEVICE_NAME || true
open -a $(xcode-select -p)/Applications/Simulator.app

ret=0
doTest $base_xctestrun ||
    retry ||
    retry ||
    retry ||
    record_video=YES retry ||
    ret=$?

if [[ $ret -eq 0 ]]; then
    if [[ $try -eq 0 ]] && [[ $celebration = yes ]]; then
        banner "\U1F389 All tests passed ON THE FIRST TRY! \U1F389"
    else
        banner "All tests passed after $try retries! ($total_failures flaky failures)"
    fi
else
    banner "${#tests_failed_this_run} Tests still failing after $try retries"
    echo "failing tests:"
    print ${(F)tests_failed_this_run}
    envman add --key TESTS_FAILED --value yes || true
fi

print ${(F)tests_failed_this_run} >> $results_directory/final-failed.txt

mergeResults
exit $ret
