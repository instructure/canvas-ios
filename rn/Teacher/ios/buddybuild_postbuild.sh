#!/usr/bin/env bash

TEACHER_APP_ID=58b0b2116096900100863eb8

if [ "$BUDDYBUILD_BRANCH" = "develop" ] && [ "$BUDDYBUILD_APP_ID" = "$TEACHER_APP_ID" ]; then
    aws s3 sync ../coverage s3://inseng-code-coverage/ios-teacher/coverage
fi
