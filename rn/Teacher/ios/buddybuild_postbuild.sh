#!/usr/bin/env bash

if [ "$BUDDYBUILD_BRANCH" = "develop" ]; then
    aws s3 sync ../coverage s3://inseng-code-coverage/ios-teacher/coverage
fi