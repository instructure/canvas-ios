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

# fail if any commands fails
set -e -o pipefail
# debug log
# set -x

LINT_CONFIG_FILE_PATH="$(pwd .swiftlint.yml)/.swiftlint.yml"

FIX=""
STRICT="--strict"
COMMAND="LINTING"

if [[ "$#" -eq 1 && $1 = "fix" ]]; then
    FIX="autocorrect"
    STRICT=""
    COMMAND="FIXING"
fi

declare -a names=("core" "student" "teacher" "parent" "TestsFoundation" "scripts")
declare -a paths=("Core" "Student" "rn/Teacher/ios" "Parent" "TestsFoundation" "scripts/swift")
arraylength=${#paths[@]}

echo "${COMMAND}"
echo ""

ret=0
for (( i=0; i<${arraylength}; i++ )); do
    echo "[${names[$i]}]"
    pushd ${paths[$i]} > /dev/null 2>&1
    CONFIG="$LINT_CONFIG_FILE_PATH"
    if [[ -f .swiftlint.yml ]]; then
       CONFIG=.swiftlint.yml
    fi
    swiftlint ${FIX} --config "${CONFIG}" ${STRICT} 2>/dev/null || ret=$?
    popd > /dev/null 2>&1
done
exit $ret
