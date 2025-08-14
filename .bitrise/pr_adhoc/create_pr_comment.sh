#!/usr/bin/env bash
#
# This file is part of Canvas.
# Copyright (C) 2024-present  Instructure, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

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
)

# Get commit information from Bitrise built-in variables
GITHUB_REPO_URL="https://github.com/instructure/canvas-ios"

# Use Bitrise's built-in variables that point to the actual source commit
COMMIT_HASH=$(echo "${GIT_CLONE_COMMIT_HASH:-$(git rev-parse HEAD)}" | cut -c1-7)
COMMIT_MESSAGE_FIRST_LINE="${GIT_CLONE_COMMIT_MESSAGE_SUBJECT:-$(git log -1 --pretty=format:'%s')}"

COLUMNS=""

for APP_NAME in "${APP_NAMES[@]}"; do
    FILE_NAME="${APP_NAME}_qr_url"

    if [[ -f "${FILE_NAME}" ]]; then
        QR_URL=$(<"${FILE_NAME}")
        echo "${APP_NAME}'s QR url is ${QR_URL}."
        COLUMNS+="<td valign=\"top\"><details open>"
        COLUMNS+="<summary>${APP_NAME}</summary>"
        COLUMNS+="<img src=\"${QR_URL}\" />"
        COLUMNS+="</details></td>"
    else
        echo "File ${FILE_NAME} not found."
    fi

done

PR_COMMENT="<h3>Builds</h3>"

if [[ -z "$COLUMNS" ]]; then
    PR_COMMENT+="<p>No apps were built for this pull request.</p>"
    PR_COMMENT+="<p><em>To trigger app builds, include a line starting with <code>builds:</code> followed by app names (Student, Teacher, Parent, or All) in your commit message.</em></p>"
else
    PR_COMMENT+="<table>"
    PR_COMMENT+="<tr>${COLUMNS}</tr>"
    PR_COMMENT+="</table>"
fi

PR_COMMENT+="<p><strong>Commit:</strong> ${COMMIT_MESSAGE_FIRST_LINE} (<a href=\"${GITHUB_REPO_URL}/commit/${COMMIT_HASH}\">${COMMIT_HASH}</a>)</p>"

printf "\nGenerated HTML snippet:\n${PR_COMMENT}"
envman add --key PR_BUILDS_COMMENT --value "${PR_COMMENT}"
