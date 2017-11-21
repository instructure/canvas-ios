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
