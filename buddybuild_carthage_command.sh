#!/bin/bash

# https://docs.buddybuild.com/builds/dependencies/carthage.html
cd "$BUDDYBUILD_WORKSPACE"
carthage checkout --no-use-binaries --use-ssh
