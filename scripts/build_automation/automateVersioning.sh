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
set -x

verifyInputs() {
	if [ -z ${APP_RELEASE_VERSION} ]; then
	    echo "variable APP_RELEASE_VERSION must be set"
	    exit 1
	fi
	
	if [ -z ${APP_NAME} ]; then
	    echo "variable APP_NAME must be set (i.e. Student, Parent, Teacher)"
	    exit 1
	fi

	# if [[ $BITRISE_GIT_BRANCH != "master" ]]; then
# 	    echo "run this job on master branch"
# 	    exit 1
# 	fi
}

checkoutReleaseBranch() {
	if [ -z $RELEASE_BRANCH ]; then
	    echo "variable RELEASE_BRANCH must be set"
	    exit 1
	fi
	
	git checkout -b $RELEASE_BRANCH origin/$BITRISE_GIT_BRANCH
}

checkInReleaseBranchAndTag() {
	#	Add the following to the scrip outside this file
#	git add Canvas/Canvas/Info.plist
#	git add Canvas/GradesWidget/Info.plist

	git commit -m "Release $BITRISE_APP_TITLE $APP_RELEASE_VERSION"

	TAG="$APP_NAME-$APP_RELEASE_VERSION"

	if git tag --list | egrep -q "^$TAG$"
	then
		git tag -d $TAG
	fi	

	if git ls-remote --tags | egrep -q "refs/tags/$TAG$"
	then
		git push origin :$TAG
	fi
	
	if git ls-remote --heads | egrep -q "refs/heads/$RELEASE_BRANCH$"
	then
		git push origin :$RELEASE_BRANCH
	fi

	git tag $TAG
	git ls-remote --tags | grep -i "$APP_NAME-"
	git push origin $RELEASE_BRANCH
	git push origin $TAG
}

updateVersionAndBuildNumberInPlist() {

	if [ -z $1 ]; then
	    echo "  updateVersionAndBuildNumberInPlist <plist_path>"
	    echo "  plist path missing"
	    exit 1
	fi
	
	PLIST_PATH=$1
	
	#	version
	/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $APP_RELEASE_VERSION" $PLIST_PATH
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BITRISE_BUILD_NUMBER" $PLIST_PATH
}

generateReleaseNotes() {
	TAG="$APP_NAME-$APP_RELEASE_VERSION"
	#	if the tag exists, use the tag 2nd to last in the list, else use the last tag in the list
	NUMBER_FROM_THE_BOTTOM=1
	if git ls-remote --tags | egrep -q "refs/tags/$TAG$"
	then
		NUMBER_FROM_THE_BOTTOM=2
	fi
	
	
	PREVIOUS_RELEASE_TAG=$(git ls-remote --tags origin | grep $APP_NAME- | sort -V | tail -$NUMBER_FROM_THE_BOTTOM | head -n 1 | awk '{print $2}' | sed -e "s/refs\/tags\///g")
	echo "previous release tag: $PREVIOUS_RELEASE_TAG"
	
	pushd scripts
	# node generate-release-notes.js --tag=$PREVIOUS_RELEASE_TAG --app=$APP_NAME
	NOTES=$(node generate-release-notes.js --tag=$PREVIOUS_RELEASE_TAG --app=$APP_NAME)
	popd

	envman add --key RELEASE_NOTES --value "$NOTES"
}

"$@"
