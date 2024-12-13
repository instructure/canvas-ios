#!/usr/bin/env bash
# fail if any commands fails
set -e
# make pipelines' return status equal the last command to exit with a non-zero status, or zero if all commands exit successfully
set -o pipefail
# debug log
# set -x

# Reads files from the working directory containing QR code URLs
# for each app and creates a PR comment from them that will be exposed
# with envman in the $PR_BUILDS_COMMENT variable.
# File format is expected in this format: Student_qr_url

declare -a APP_NAMES=(
    "Student"
    "Teacher"
    "Parent"
    "Horizon"
)

COLUMNS=""

for APP_NAME in "${APP_NAMES[@]}"; do
	FILE_NAME="${APP_NAME}_qr_url"


	if [[ -f "${FILE_NAME}" ]]; then
		QR_URL=$(<"${FILE_NAME}")
		echo "${APP_NAME}'s QR url is ${QR_URL}."
        COLUMNS+="<td><details>"
        COLUMNS+="<summary>${APP_NAME}</summary>"
        COLUMNS+="<img src='${QR_URL}' />"
        COLUMNS+="</details></td>"
    else
		echo "File ${FILE_NAME} not found."
	fi

done

PR_COMMENT="<h1>Builds</h1>"
PR_COMMENT+="<table>"
PR_COMMENT+="<tr>${COLUMNS}</tr>"
PR_COMMENT+="</table>"

printf "\nGenerated HTML snippet:\n${PR_COMMENT}"
envman add --key PR_BUILDS_COMMENT --value $PR_COMMENT
