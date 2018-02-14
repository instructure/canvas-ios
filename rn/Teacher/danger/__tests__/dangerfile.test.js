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

/* @flow */

import {
  annotations,
  jira,
  untestedFiles,
  packages,
} from '../../dangerfile'
import { warn, danger, markdown } from 'danger'
import path from 'path'

jest
  .mock('danger')
  .mock('fs', () => require('../../src/__mocks__/fs.js'))

const GITHUB = {
  pr: {
    head: {
      ref: 'master',
      repo: {
        html_url: 'https://github.com/instructure/ios',
      },
    },
  },
}

beforeEach(() => {
  jest.resetAllMocks()
  danger.__setGithub(GITHUB)
})

describe('annotations', () => {
  const MOCK_FILE_INFO = {
    '/path/to/file1.js': '/* @flow */\nfile1 contents',
    '/path/to/file2.js': '// @flow\nfile2 contents',
    '/path/to/file3.js': 'file2 contents',
  }

  const GIT = {
    created_files: Object.keys(MOCK_FILE_INFO),
  }

  beforeEach(() => {
    danger.__setGit(GIT)

    // nest paths because dana is nested
    const files = {}
    for (const p in MOCK_FILE_INFO) {
      files[path.join('../../', p)] = MOCK_FILE_INFO[p]
    }

    // $FlowFixMe
    require('fs').__setMockFiles(files)
  })

  it('warns if files are not annotated', () => {
    annotations()
    const warning = 'Please add @flow to these files: <a href=\'https://github.com/instructure/ios/blob/master/path/to/file3.js\'>/path/to/file3.js</a>'
    expect(warn).toHaveBeenCalledWith(warning)
  })
})

describe('jira', () => {
  it('warns if there is not a reference to a jira ticket', () => {
    danger.__setGithub({ pr: { title: 'No reference', body: 'No reference' } })
    jira()
    expect(warn).toHaveBeenCalled()
  })

  it('does not warn if there is a reference in the title', () => {
    danger.__setGithub({ pr: { title: '[Mbl-1234] Title', body: 'No reference' } })
    jira()
    expect(warn).not.toHaveBeenCalled()
    expect(markdown).toHaveBeenCalledWith('[MBL-1234](https://instructure.atlassian.net/browse/MBL-1234)')
  })

  it('does not warn if there is a reference in the body', () => {
    danger.__setGithub({ pr: { title: 'Title', body: 'Body mbl-1234' } })
    jira()
    expect(warn).not.toHaveBeenCalled()
    expect(markdown).toHaveBeenCalledWith('[MBL-1234](https://instructure.atlassian.net/browse/MBL-1234)')
  })
})

describe('untestedFiles', () => {
  const CREATED_FILES = [
    '/src/path/to/file1.js',
    '/src/path/to/file2.js',
    '/src/path/to/__tests__/file2.js',
  ]

  beforeEach(() => {
    danger.__setGit({ created_files: CREATED_FILES })
  })

  it('warns if file created without corresponding test file', () => {
    untestedFiles()
    const warning = 'Please add tests for these files: <a href=\'https://github.com/instructure/ios/blob/master/src/path/to/file1.js\'>/src/path/to/file1.js</a>'
    expect(warn).toHaveBeenCalledWith(warning)
  })
})

describe('packages', () => {
  it('warns if package.json is modified without modifying yarn.lock', () => {
    danger.__setGit({
      modified_files: ['package.json'],
    })
    packages()
    expect(warn).toHaveBeenCalled()
  })

  it('does not warn if yarn.lock is modified along with package.json', () => {
    danger.__setGit({
      modified_files: ['package.json', 'yarn.lock'],
    })
    packages()
    expect(warn).not.toHaveBeenCalled()
  })
})
