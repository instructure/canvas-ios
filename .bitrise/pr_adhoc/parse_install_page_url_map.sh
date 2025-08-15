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
set -x

# Parse BITRISE_PUBLIC_INSTALL_PAGE_URL_MAP and set environment variables for each app
if [[ -z "$BITRISE_PUBLIC_INSTALL_PAGE_URL_MAP" ]]; then
    echo "BITRISE_PUBLIC_INSTALL_PAGE_URL_MAP is empty - no IPAs were deployed"
    exit 0
fi

echo "BITRISE_PUBLIC_INSTALL_PAGE_URL_MAP: $BITRISE_PUBLIC_INSTALL_PAGE_URL_MAP"

# Parse the URL map format: "file1.ipa=>url1|file2.ipa=>url2|..."
IFS='|' read -ra INSTALL_MAPPINGS <<< "$BITRISE_PUBLIC_INSTALL_PAGE_URL_MAP"

for mapping in "${INSTALL_MAPPINGS[@]}"; do
    if [[ "$mapping" == *"=>"* ]]; then
        # Split on '=>' using parameter expansion
        file_path="${mapping%%=>*}"
        install_url="${mapping#*=>}"
        
        # Extract app name from file path (e.g., "/path/to/Student.ipa" -> "Student")
        filename=$(basename "$file_path")
        app_name="${filename%.ipa}"
        
        echo "Found deployment for ${app_name}: ${install_url}"
        
        # Set environment variables for this app
        envman add --key "DEPLOYED_${app_name}_URL" --value "$install_url"
    fi
done