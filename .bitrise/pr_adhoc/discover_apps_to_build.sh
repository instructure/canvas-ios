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

# This script inspects the pull request's description and if it contains an app's name
# it sets the appropriate environment variable.
#
# Outputs if conditions are met for each app:
# - $REQUIRE_PARENT=true
# - $REQUIRE_TEACHER=true
# - $REQUIRE_STUDENT=true
# - $REQUIRE_HORIZON=true

if [[ ! -z $BITRISE_PULL_REQUEST ]]; then
  envman add --key PR_NUMBER --value $BITRISE_PULL_REQUEST
else
  envman add --key PR_NUMBER --value "NOT_PR"
fi

if [[ $BITRISE_GIT_MESSAGE == *"Student"* ]]; then
  envman add --key REQUIRE_STUDENT --value "true"
fi

if [[ $BITRISE_GIT_MESSAGE == *"Teacher"* ]]; then
  envman add --key REQUIRE_TEACHER --value "true"
fi

if [[ $BITRISE_GIT_MESSAGE == *"Parent"* ]]; then
  envman add --key REQUIRE_PARENT --value "true"
fi

if [[ $BITRISE_GIT_MESSAGE == *"Horizon"* ]]; then
  envman add --key REQUIRE_HORIZON --value "true"
fi

if [[ $BITRISE_GIT_MESSAGE == *"affects: All"* ]]; then
  envman add --key REQUIRE_PARENT --value "true" &&
  envman add --key REQUIRE_TEACHER --value "true" &&
  envman add --key REQUIRE_STUDENT --value "true" &&
  envman add --key REQUIRE_HORIZON --value "true"
fi
