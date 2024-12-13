#!/usr/bin/env bash
# fail if any commands fails
set -e
# make pipelines' return status equal the last command to exit with a non-zero status, or zero if all commands exit successfully
set -o pipefail
# debug log
# set -x

declare -a APP_NAMES=(
    "BITRISE_PUBLIC_INSTALL_PAGE_QR_CODE_IMAGE_URL_Student:Student"
    "BITRISE_PUBLIC_INSTALL_PAGE_QR_CODE_IMAGE_URL_Teacher:Teacher"
    "BITRISE_PUBLIC_INSTALL_PAGE_QR_CODE_IMAGE_URL_Parent:Parent"
    "BITRISE_PUBLIC_INSTALL_PAGE_QR_CODE_IMAGE_URL_Horizon:Horizon"
)

COLUMNS=""

for PAIR in "${APP_NAMES[@]}"; do
    QR_URL="${PAIR%%:*}"
    APP_NAME="${PAIR#*:}"
    if [[ -n "${!QR_URL}" ]]; then
        COLUMNS+="<td><details>"
        COLUMNS+="<summary>${APP_NAME}</summary>"
        COLUMNS+="<img src='${!QR_URL}' />"
        COLUMNS+="</details></td>"
    fi
done

PR_COMMENT="<h1>Builds</h1>"
PR_COMMENT+="<table>"
PR_COMMENT+="<tr>${COLUMNS}</tr>"
PR_COMMENT+="</table>"

envman add --key PR_BUILDS_COMMENT --value $PR_COMMENT
