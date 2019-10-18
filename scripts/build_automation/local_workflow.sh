#!/bin/zsh

set -euxo pipefail

if [[ $# -ne 1 ]]; then
    echo "usages: ./scripts/build_automation/local_workflow.sh (danger|nightly)"
    exit 1
fi

bitrise run default --config scripts/build_automation/bitrise_workflows/$1.yml
