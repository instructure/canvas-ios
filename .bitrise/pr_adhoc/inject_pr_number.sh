#!/usr/bin/env bash
#
# This file is part of Canvas.
# Copyright (C) 2026-present  Instructure, Inc.
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

set -e
set -o pipefail

if [ -z "${PR_NUMBER}" ]; then
    echo "PR_NUMBER is not set, skipping injection"
    exit 0
fi

PLIST="${INST_XCODE_SCHEME}/${INST_XCODE_SCHEME}/Info.plist"
/usr/libexec/PlistBuddy -c "Set :PRNumber ${PR_NUMBER}" "$PLIST"
echo "Injected PR_NUMBER=${PR_NUMBER} into ${PLIST}"
