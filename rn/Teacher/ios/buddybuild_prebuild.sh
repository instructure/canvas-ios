#!/usr/bin/env bash -e

# react native teacher dependencies
pushd ../../../
carthage checkout --no-use-binaries
popd

cd ../

yarn run lint

yarn run flow

yarn run test

cd ios
