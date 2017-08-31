//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/* @flow */

const path = require('path')

const fs = jest.genMockFromModule('fs')

let mockFiles = Object.create(null)
function __setMockFiles (newMockFiles) {
  mockFiles = Object.create(null)
  for (const file in newMockFiles) {
    const dir = path.dirname(file)

    if (!mockFiles[dir]) {
      mockFiles[dir] = {}
    }
    mockFiles[dir][path.basename(file)] = newMockFiles[file]
  }
}

function readFileSync (file) {
  const dir = path.dirname(file)
  const name = path.basename(file)
  return mockFiles[dir][name]
}

fs.__setMockFiles = __setMockFiles
fs.readFileSync = readFileSync

module.exports = fs
