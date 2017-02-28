#!/usr/bin/env bash

TEACHER_APP_ID=58b0b2116096900100863eb8
TEACHER_PATTERN='rn\/Teacher'

PARENT_APP_ID=5810b402f729340100dbfd21
PARENT_PATTERN='Parent\/\|Frameworks\/'

CANVAS_APP_ID=5810af375fb3a60100a3e6e9
CANVAS_PATTERN='Canvas\/\|Frameworks\/'

EVERYTHING_BAGEL_APP_ID=580fa30f129afa0100079232
FRAMEWORKS_PATTERN='Frameworks\/'

diff="$(git diff --name-only origin/${BUDDYBUILD_BASE_BRANCH})"

check_app_diff ()
{
  if [[ $BUDDYBUILD_APP_ID = $1 ]]; then
    echo $diff | grep $2
    exit_status=$?

    if [[ $exit_status = 1 ]]; then
      echo "Found no changes for app ${BUDDYBUILD_APP_ID}. Cancelling build."
      curl -X POST -H "Authorization: Bearer ${API_TOKEN}" https://api.buddybuild.com/v1/builds/$BUDDYBUILD_BUILD_ID/cancel
    else
      echo "Found changes for app ${BUDDYBUILD_APP_ID}. Continuing build."
    fi
  fi
}

shortcircuit_build ()
{
  check_app_diff $TEACHER_APP_ID $TEACHER_PATTERN
  check_app_diff $PARENT_APP_ID $PARENT_PATTERN
  check_app_diff $CANVAS_APP_ID $CANVAS_PATTERN
  check_app_diff $EVERYTHING_BAGEL_APP_ID $FRAMEWORKS_PATTERN
}

if [ "$BUDDYBUILD_BRANCH" = "develop" ]; then
    # install the aws cli
    pip install --upgrade --user awscli
else
    shortcircuit_build
fi
