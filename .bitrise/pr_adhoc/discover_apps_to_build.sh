#!/usr/bin/env bash
#
# This file is part of Canvas.
# Copyright (C) 2024-present  Instructure, Inc.
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
set -e
# make pipelines' return status equal the last command to exit with a non-zero status, or zero if all commands exit successfully
set -o pipefail
# debug log
# set -x

# This script inspects the pull request's commit message for a line starting with "builds:"
# and sets environment variables for the apps mentioned in that line.
# If no "builds:" line is found, no apps will be marked for building.
#
# Expected format: "builds: Student, Teacher, Parent" or "builds: All"
#
# Outputs if conditions are met for each app:
# - $REQUIRE_PARENT=true
# - $REQUIRE_TEACHER=true
# - $REQUIRE_STUDENT=true

if [[ ! -z $BITRISE_PULL_REQUEST ]]; then
    envman add --key PR_NUMBER --value $BITRISE_PULL_REQUEST
else
    envman add --key PR_NUMBER --value "NOT_PR"
fi

BUILDS_LINE=$(echo "$BITRISE_GIT_MESSAGE" | grep -i "^builds:" || true)

if [[ -z "$BUILDS_LINE" ]]; then
    echo "No 'builds:' line found in pull request message. No apps will be built."
    echo "To build apps, include a line starting with 'builds:' followed by app names (Student, Teacher, Parent, or All)."
    exit 0
fi

echo "Found builds line: $BUILDS_LINE"

if [[ $BUILDS_LINE == *"Student"* ]]; then
    envman add --key REQUIRE_STUDENT --value "true"
    echo "✓ Student app marked as required."
fi

if [[ $BUILDS_LINE == *"Teacher"* ]]; then
    envman add --key REQUIRE_TEACHER --value "true"
    echo "✓ Teacher app marked as required."
fi

if [[ $BUILDS_LINE == *"Parent"* ]]; then
    envman add --key REQUIRE_PARENT --value "true"
    echo "✓ Parent app marked as required."
fi

if [[ $BUILDS_LINE == *"All"* ]]; then
    envman add --key REQUIRE_PARENT --value "true" &&
    envman add --key REQUIRE_TEACHER --value "true" &&
    envman add --key REQUIRE_STUDENT --value "true"
    echo "✓ All apps marked as required (Student, Teacher, Parent)."
fi
