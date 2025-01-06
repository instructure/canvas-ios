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

# Writes the contents of the $BITRISE_PUBLIC_INSTALL_PAGE_QR_CODE_IMAGE_URL variable
# to a file named $INST_XCODE_SCHEME_qr_url to the working directory.
# We do this because we can't export variables with envman if the workflow is triggered
# via the "Bitrise Run" step.

echo "${BITRISE_PUBLIC_INSTALL_PAGE_QR_CODE_IMAGE_URL}" > "${INST_XCODE_SCHEME}_qr_url"
