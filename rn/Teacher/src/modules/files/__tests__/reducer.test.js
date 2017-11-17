//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
