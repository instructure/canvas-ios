#!/usr/bin/env bash

# react native teacher dependencies
pushd ../../../
carthage checkout --no-use-binaries
popd

cd ../
exit_status=1

yarn run lint
exit_status=$?

yarn run flow
exit_status=$?

exit $exit_status
cd ios
