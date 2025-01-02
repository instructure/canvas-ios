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
    "Horizon"
)

COLUMNS=""

for APP_NAME in "${APP_NAMES[@]}"; do
	FILE_NAME="${APP_NAME}_qr_url"

	if [[ -f "${FILE_NAME}" ]]; then
		QR_URL=$(<"${FILE_NAME}")
		echo "${APP_NAME}'s QR url is ${QR_URL}."
        COLUMNS+="<td style=\"vertical-align: top; min-width: 180px;\"><details>"
        COLUMNS+="<summary>${APP_NAME}</summary>"
        COLUMNS+="<img src=\"${QR_URL}\" />"
        COLUMNS+="</details></td>"
    else
		echo "File ${FILE_NAME} not found."
	fi

done

PR_COMMENT="<h3>Builds</h3>"
PR_COMMENT+="<table>"
PR_COMMENT+="<tr>${COLUMNS}</tr>"
PR_COMMENT+="</table>"

printf "\nGenerated HTML snippet:\n${PR_COMMENT}"
envman add --key PR_BUILDS_COMMENT --value "${PR_COMMENT}"
