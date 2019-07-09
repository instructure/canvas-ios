//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
    const action = Actions.filesUpdated([file], 'path', 'id', 'type')
    expect(action).toMatchObject({ payload: { files: [file], path: 'path', id: 'id', type: 'type' } })
  })

  it('folders updated', () => {
    const folder = template.folder()
    const action = Actions.foldersUpdated([folder], 'path', 'id', 'type')
    expect(action).toMatchObject({ payload: { folders: [folder], path: 'path', id: 'id', type: 'type' } })
  })

  it('folder updated', () => {
    const folder = template.folder()
    const action = Actions.folderUpdated(folder, 'id', 'type')
    expect(action).toMatchObject({ payload: { folder: folder, id: 'id', type: 'type' } })
  })
})
