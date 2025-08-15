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

# This script creates a GitHub PR comment with QR codes for deployed Canvas iOS apps.
# It reads *_QR_CODE_URL variables (set by Bitrise's create-install-page-qr-code steps)
# to generate an HTML table showing app icons and QR codes for installation.

# Get commit information from Bitrise built-in variables
GITHUB_REPO_URL="https://github.com/instructure/canvas-ios"
COMMIT_HASH=$(echo "${GIT_CLONE_COMMIT_HASH:-$(git rev-parse HEAD)}" | cut -c1-7)
COMMIT_MESSAGE_FIRST_LINE="${GIT_CLONE_COMMIT_MESSAGE_SUBJECT:-$(git log -1 --pretty=format:'%s')}"

# HTML escape the commit message to prevent issues with special characters
COMMIT_MESSAGE_ESCAPED=$(echo "$COMMIT_MESSAGE_FIRST_LINE" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')

COMMIT_LINE="<p><strong>Commit:</strong> ${COMMIT_MESSAGE_ESCAPED} (<a href=\"${GITHUB_REPO_URL}/commit/${COMMIT_HASH}\">${COMMIT_HASH}</a>)</p>"

# Check if any apps have QR codes (which means they were built, deployed, and have valid QR codes)
if [[ -z "${Student_QR_CODE_URL:-}${Teacher_QR_CODE_URL:-}${Parent_QR_CODE_URL:-}" ]]; then
    envman add --key PR_BUILDS_COMMENT --value "<h3>Builds</h3><p>No apps were built for this pull request.</p><p><em>To trigger app builds, include a line starting with <code>builds:</code> followed by app names (Student, Teacher, Parent, or All) in your pull request's message.</em></p>${COMMIT_LINE}"
    exit 0
fi

# Generate PR comment
COLUMNS=""

for app_name in "Student" "Teacher" "Parent"; do
    qr_url_var="${app_name}_QR_CODE_URL"
    
    # Only process apps that have QR codes (which means they were built, deployed, and QR generated)
    if [[ -n "${!qr_url_var:-}" ]]; then
        case $app_name in
            "Student") LOGO="<img src=\"https://raw.githubusercontent.com/instructure/canvas-ios/refs/heads/master/Student/Student/Assets.xcassets/student-logomark.imageset/student%20light.svg\" width=\"12\" height=\"12\" />" ;;
            "Teacher") LOGO="<img src=\"https://raw.githubusercontent.com/instructure/canvas-ios/refs/heads/master/Teacher/Teacher/Assets.xcassets/teacher-logomark.imageset/teacher%20light.svg\" width=\"12\" height=\"12\" />" ;;
            "Parent") LOGO="<img src=\"https://raw.githubusercontent.com/instructure/canvas-ios/refs/heads/master/Parent/Parent/Assets.xcassets/parent-logomark.imageset/parent%20light.svg\" width=\"12\" height=\"12\" />" ;;
            *) LOGO="" ;;
        esac
        
        # Get the install URL and QR URL
        install_url_var="DEPLOYED_${app_name}_URL"
        install_url="${!install_url_var}"
        qr_url="${!qr_url_var}"
        
        COLUMNS+="<td valign=\"top\"><details open>"
        COLUMNS+="<summary>${LOGO} ${app_name}</summary>"
        COLUMNS+="<a href=\"${install_url}\">"
        COLUMNS+="<img src=\"${qr_url}\" />"
        COLUMNS+="</a>"
        COLUMNS+="</details></td>"
        
        echo "Added ${app_name} to PR comment with QR: ${qr_url}"
    fi
done

PR_COMMENT="<h3>Builds</h3>"
PR_COMMENT+="<table>"
PR_COMMENT+="<tr>${COLUMNS}</tr>"
PR_COMMENT+="</table>"

PR_COMMENT+="${COMMIT_LINE}"

echo -e "\nGenerated HTML snippet:\n${PR_COMMENT}"
envman add --key PR_BUILDS_COMMENT --value "${PR_COMMENT}"
