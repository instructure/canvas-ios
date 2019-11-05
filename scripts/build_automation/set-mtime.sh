#!/bin/zsh
set -euxo pipefail

function setLastChanged {
    # Set time on all files from commit
    git fetch origin $1
    git checkout $1
    TIMESTAMP=$(date -r $(git log -1 --format="%at") +%Y%m%d%H%M.%S)
    find . -exec touch -t $TIMESTAMP {} +

    # Set all changed files to now
    git checkout -
}

# try getting timestamp information from the cache
if [[ -f tmp/cache-commit-hash ]]; then
    setLastChanged $(cat tmp/cache-commit-hash)
else
    # fall back to assuming master was the last thing to produce a cache
    setLastChanged master
fi
