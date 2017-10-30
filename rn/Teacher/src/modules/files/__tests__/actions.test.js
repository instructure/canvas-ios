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

/**
 * @flow
 */

import Actions from '../actions'

const template = {
  ...require('../../../__templates__/file'),
  ...require('../../../__templates__/folder'),
}

describe('CourseFileList', () => {
  it('files updated', () => {
    const file = template.file()
    expect(Actions.filesUpdated([file])).toMatchObject({ payload: { files: [file] } })
  })

  it('folders updated', () => {
    const folder = template.folder()
    expect(Actions.foldersUpdated([folder])).toMatchObject({ payload: { folders: [folder] } })
  })
})
