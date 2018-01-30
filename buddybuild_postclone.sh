#!/usr/bin/env bash

TEACHER_UI_JOB_ID=58c981b73749ca0100c1abb3

if [[ "$BUDDYBUILD_BRANCH" = "develop" ]]; then
    # install the aws cli
    pip install --upgrade --user awscli
fi

cd rn/Teacher
yarn install
