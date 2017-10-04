#!/usr/bin/env bash

if [ "$BUDDYBUILD_BRANCH" = "develop" ] && [ "$BUDDYBUILD_SCHEME" != "Teacher - BB - Jest" ]; then
    aws s3 sync ../coverage s3://inseng-code-coverage/ios-teacher/coverage
fi
