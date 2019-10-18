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
# set -x

xcrun xcresulttool get --format json --path scripts/coverage/citests.xcresult | \
    jq '[.issues.testFailureSummaries._values[] | {
        TestBundle: .producingTarget._value,
        Message: .message._value,
        Location: .documentLocationInCreatingWorkspace.url._value,
        Build: env.BITRISE_BUILD_URL,
        Branch: env.BITRISE_GIT_BRANCH,
        Commit: env.BITRISE_GIT_COMMIT,
    } + (.testCaseName._value | split(".") | {
        TestClass: .[0],
        TestName: .[1],
    })]' > flaky.json

curl -LF 'data=<flaky.json' -X POST "$POST_TO_GOOGLE_SHEETS_URL"
jq -ac '.[]' < flaky.json |\
    while IFS= read -r line; do
        curl -X POST -H "Content-Type: application/json" --data-raw "$line" "$SUMO_ENDPOINT_URL"
    done
