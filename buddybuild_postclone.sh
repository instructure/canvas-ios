#!/usr/bin/env bash

TEACHER_APP_ID=58b0b2116096900100863eb8
TEACHER_UI_JOB_ID=58c981b73749ca0100c1abb3
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
      curl -X POST -H "Authorization: Bearer ${API_TOKEN}" https://api.buddybuild.com/v1/builds/$BUDDYBUILD_BUILD_ID/cancel?cancel_successfully=1
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

if [[ "$BUDDYBUILD_BRANCH" = "develop" ]]; then
    # install the aws cli
    pip install --upgrade --user awscli
fi

if [[ "$BUDDYBUILD_BASE_BRANCH" = "develop" ]]; then
    shortcircuit_build
fi

if [[ "$BUDDYBUILD_APP_ID" = $TEACHER_UI_JOB_ID ]]; then
  # list rubies (ruby-2.2.5, ruby-2.3.1, ruby-2.4.1)
  chruby

  # select ruby
  chruby ruby-2.4.1

  # update rubygems
  echo "gem: --no-document" >> ~/.gemrc
  gem update --system --no-document

  # install fastlane
  gem install fastlane --no-document

  # authorize simulator
  # https://github.com/wix/AppleSimulatorUtils
  brew tap wix/brew
  brew install --HEAD applesimutils
  applesimutils --simulator "iPhone 7 Plus" --bundle "com.instructure.ios.teacher" --setPermissions "notifications=NO"

  fastlane seed_teacher
fi
