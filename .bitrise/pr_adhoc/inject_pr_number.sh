#!/usr/bin/env bash
set -e
set -o pipefail

if [ -z "${PR_NUMBER}" ]; then
    echo "PR_NUMBER is not set, skipping injection"
    exit 0
fi

PLIST="${INST_XCODE_SCHEME}/${INST_XCODE_SCHEME}/Info.plist"
/usr/libexec/PlistBuddy -c "Set :PRNumber ${PR_NUMBER}" "$PLIST"
echo "Injected PR_NUMBER=${PR_NUMBER} into ${PLIST}"
