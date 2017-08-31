#!/bin/bash

# https://docs.buddybuild.com/builds/dependencies/carthage.html
# Note: This file must exist next to the project.
# The custom carthage command will be ignored when located at the repo root.
cd "$BUDDYBUILD_WORKSPACE"
carthage checkout --no-use-binaries --use-ssh
