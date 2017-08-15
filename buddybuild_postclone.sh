#!/usr/bin/env bash

TEACHER_UI_JOB_ID=58c981b73749ca0100c1abb3

if [[ "$BUDDYBUILD_BRANCH" = "develop" ]]; then
    # install the aws cli
    pip install --upgrade --user awscli
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

  fastlane seed_teacher
fi
