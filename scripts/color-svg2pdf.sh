#!/bin/zsh
#
# This file is part of Canvas.
# Copyright (C) 2019-present  Instructure, Inc.
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

set -euo pipefail

if ! cairosvg --version > /dev/null; then
    echo "cairosvg not found, install using: 'pip3 install cairosvg'"
    exit 1
fi

if [[ $# -ne 2 ]]; then
    echo "usage: ./scripts/color-svg2pdf.sh in.svg out.pdf"
    exit 1
fi

cairosvg $1 --dpi 72 |
    LC_ALL=C sed 's/cairo [^ ]* (https:\/\/cairographics.org)//' > $2
