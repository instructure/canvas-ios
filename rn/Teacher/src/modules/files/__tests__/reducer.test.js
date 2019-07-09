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
import { filesData, foldersData } from '../reducer'

const template = {
  ...require('../../../__templates__/file'),
  ...require('../../../__templates__/folder'),
  ...require('../../../redux/__templates__/app-state'),
}

describe('CourseFileList', () => {
  it('files updated', () => {
    const file = template.file()
    const path = 'path'
    const id = '123'
    const type = 'Course'
    const action = Actions.filesUpdated([file], path, id, type)
    const result = filesData(template.appState(), action)
    expect(result).toMatchObject({
      [`${type}-${id}`]: {
        [path]: [file],
      },
    })
  })

  it('folders updated', () => {
    const folder = template.folder()
    const path = 'path'
    const id = '123'
    const type = 'Course'
    const action = Actions.foldersUpdated([folder], path, id, type)
    const result = foldersData(template.appState(), action)
    expect(result).toMatchObject({
      [`${type}-${id}`]: {
        [path]: [folder],
      },
    })
  })

  it('folder updated edge case', () => {
    const folder = template.folder({ full_name: 'course files/folder' })
    const path = 'course files'
    const id = '123'
    const type = 'Course'
    const action = Actions.folderUpdated(folder, id, type)
    const result = foldersData({}, action)
    expect(result).toMatchObject({
      [`${type}-${id}`]: {
        [path]: [folder],
      },
    })
  })

  it('folder updated edge case', () => {
    const folder = template.folder({ full_name: 'course files/folder', locked: true })
    const path = 'course files'
    const id = '123'
    const type = 'Course'
    const action = Actions.folderUpdated(folder, id, type)
    const state = {
      [`${type}-${id}`]: {
        [path]: [{ ...folder, locked: false }],
      },
    }
    const result = foldersData(state, action)
    expect(result).toMatchObject({
      [`${type}-${id}`]: {
        [path]: [folder],
      },
    })
  })
})
