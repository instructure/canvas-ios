#!/usr/bin/env bash
# fail if any commands fails
set -e
# make pipelines' return status equal the last command to exit with a non-zero status, or zero if all commands exit successfully
set -o pipefail
# debug log
# set -x

# Writes the contents of the$BITRISE_PUBLIC_INSTALL_PAGE_QR_CODE_IMAGE_URL variable
# to a file named $INST_XCODE_SCHEME_qr_url to the working directory.
# We do this because we can't export variables with envman if the workflow is triggered
# via the "Bitrise Run" step.

echo "${BITRISE_PUBLIC_INSTALL_PAGE_QR_CODE_IMAGE_URL}" > "${INST_XCODE_SCHEME}_qr_url"