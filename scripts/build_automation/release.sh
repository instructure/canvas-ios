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
set -e
# debug log
# set -x

printHelp() {
	echo "yarn release <app name> <version> [--branch <branch>] <bitrise app slug> <bitrise token>"
	echo "    app name - (i.e. Student, Teacher, Parent)"
	echo "    version - version for the next release"
	echo "    --branch - (optional) branch to start the release from (defaults to master)"
	echo "    *bitrise slug - bitrise slug for app url"
	echo "    *bitrise token - token from bitrise"
	echo "    * optional if you have a release.config file with the slugs and tokens of each app"
}

if [ -z ${1} ]; then
    echo "app name missing"
	printHelp
    exit 1
fi

if [ -z ${2} ]; then
    echo "version missing"
	printHelp
    exit 1
fi

APP_NAME=$1
VERSION=$2
shift 2

BRANCH="master"
if [ "${1}" = "--branch" ]; then
	if [ -z "${2}" ]; then
		echo "branch name missing after --branch"
		printHelp
		exit 1
	fi
 
	BRANCH=$2
	shift 2
fi

CONFIG_FILE="$(dirname "${BASH_SOURCE[0]}")/release.config"
if [ -e $CONFIG_FILE ]
then
	source $CONFIG_FILE
	SLUG=$BITRISE_SLUG
	TOKEN=$BITRISE_TOKEN

else
	if [ -z ${1} ]; then
	    echo "bitrise slug missing"
		printHelp
	    exit 1
	fi

	if [ -z ${2} ]; then
	    echo "bitrise token missing"
		printHelp
	    exit 1
	fi

	SLUG=$1
	TOKEN=$2

fi

echo "Starting release for $APP_NAME $VERSION from branch '$BRANCH'"

curl https://app.bitrise.io/app/$SLUG/build/start.json --data '{
    "build_params": {
        "branch": "'"$BRANCH"'",
        "environments": [
            {
                "is_expand": true,
                "mapped_to": "APP_RELEASE_VERSION",
                "value": "'"$VERSION"'"
            },
            {
                "is_expand": true,
                "mapped_to": "APP_RELEASE_TARGET",
                "value": "'"$APP_NAME"'"
            }
        ],
        "workflow_id": "app-store-trigger"
    },
    "hook_info": {
        "build_trigger_token": "'"$TOKEN"'",
        "type": "bitrise"
    },
    "triggered_by": "release.sh shell script"
}'
