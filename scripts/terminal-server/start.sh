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

# Start the server in a background terminal with logging enabled
screen -d -m -L node ./scripts/terminal-server/server.js

# Wait until screen creates the log file and writes something into it
until [ -s screenlog.0 ]; do sleep 1; done

# Dump logs of server.js to console for debugging purposes
cat screenlog.0

# If the log doesn't contain the successful start log we exit with an error to make the caller yarn command fail
if ! grep -q "Terminal server started." screenlog.0; then
  exit 1
fi
