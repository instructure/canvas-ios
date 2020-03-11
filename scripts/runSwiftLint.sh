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

if [ "$#" -eq 1 ]; then

	if [ $1 = "fix" ]; then
		FIX="autocorrect"
		STRICT=""
		COMMAND="FIXING"
	fi

fi

declare -a names=("core" "student" "teacher" "parent" "TestsFoundation")
declare -a paths=("Core" "Student" "rn/Teacher/ios" "Parent" "TestsFoundation")
arraylength=${#paths[@]}

echo "${COMMAND}"
echo ""

for (( i=0; i<${arraylength}; i++ ));
do
	echo "[${names[$i]}]"
	pushd ${paths[$i]} > /dev/null 2>&1
	swiftlint ${FIX} --config ${LINT_CONFIG_FILE_PATH} ${STRICT} 2>&1 #> /dev/null
	popd > /dev/null 2>&1
done
