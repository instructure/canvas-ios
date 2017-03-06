#!/usr/bin/env bash -e

# react native teacher dependencies
pushd ../../../
carthage checkout --no-use-binaries
popd

pushd ../
yarn run lint
yarn run flow
yarn run test

if [ "$BUDDYBUILD_BASE_BRANCH" != "" ]; then
    aws s3 cp s3://inseng-code-coverage/ios-teacher/coverage/coverage-summary.json ./coverage-summary-develop.json
    export DANGER_FAKE_CI="YEP"
    export DANGER_TEST_REPO="$BUDDYBUILD_REPO_SLUG"
    export DANGER_TEST_PR="$BUDDYBUILD_PULL_REQUEST"
    yarn run danger
fi

popd