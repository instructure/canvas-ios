#!/usr/bin/env bash

if [ "$BUDDYBUILD_BRANCH" = "develop" ]; then
    # install the aws cli
    pip install --upgrade --user awscli
fi
