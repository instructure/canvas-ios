#!/usr/bin/env bash -e

retry_command() {
  # retry up to 3 times
  for try_count in {1..2}; do
    set +e

    "$@"
    command_exit_code=$?

    set -e

    if [[ ${command_exit_code} -ne 0 ]]; then
      # command should error if we're on the last attempt.
      if [[ ${try_count} = 2 ]]; then
        "$@"
      fi
      continue
    else
      break
    fi
  done
}

# todo: update student app id after PR is merged and the tmp job is removed.
STUDENT_EARLGREY_APP_ID="5acff803582ab800014018cd"
TEACHER_RN_EARLGREY_RUN_JOB_ID="5a31998ddb6814000138d68f"
if [[ "${BUDDYBUILD_APP_ID}" == "${TEACHER_RN_EARLGREY_RUN_JOB_ID}" || "${BUDDYBUILD_APP_ID}" == "${STUDENT_EARLGREY_APP_ID}" ]]
then
  echo "EarlGrey run job detected. Installing Java 8 for gRPC"
  retry_command brew update
  retry_command brew tap caskroom/versions
  retry_command brew cask install java8
  sudo ln -sf $(/usr/libexec/java_home)/bin/java /usr/bin/java
  exit 0
fi
