#!/bin/zsh
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

if [ $# -ne 2 ]; then
	echo "This script lists commits between the version's tag and the master branch affecting the given app."
	echo "Usage: $0 <Student|Teacher|Parent> <version>"
	exit 1
fi

tag_name="$1-$2"

if ! git rev-parse -q --verify "refs/tags/$tag_name" >/dev/null; then
	echo "Tag '$tag_name' not found."
	exit 1
fi

# -i to do a case insensitive search
# --grep to list commits containing the affects string and the app's name in one line
# --oneline to print commits in a short format
git log -i --grep="affects:.*$1" --oneline master...$tag_name
