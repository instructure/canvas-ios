#!/usr/bin/env bash -e

retry_command() {
  for try_count in {1..3}; do
    set +e

    "$@"
    command_exit_code=$?

    set -e

    if [[ ${command_exit_code} -ne 0 ]]; then
      continue
    else
      break
    fi
  done
}

# react native teacher dependencies
pushd ../../../
retry_command carthage checkout --no-use-binaries
popd

echo "Using node: $(node -v)"

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
