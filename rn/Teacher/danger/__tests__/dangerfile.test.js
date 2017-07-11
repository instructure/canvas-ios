/* @flow */

import {
  annotations,
  jira,
  untestedFiles,
  packages,
} from '../../dangerfile'
import { warn, danger } from 'danger'
import path from 'path'

jest
  .mock('danger')
  .mock('fs')

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

    require('fs').__setMockFiles(files)
  })

  it('warns if files are not annotated', () => {
    annotations()
    const warning = 'These new JS files do not have Flow enabled: <a href=\'https://github.com/instructure/ios/blob/master/path/to/file3.js\'>/path/to/file3.js</a>'
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
    danger.__setGithub({ pr: { title: '[MBL-1234] Title', body: 'No reference' } })
    jira()
    expect(warn).not.toHaveBeenCalled()
  })

  it('does not warn if there is a reference in the body', () => {
    danger.__setGithub({ pr: { title: 'Title', body: 'Body MBL-1234' } })
    jira()
    expect(warn).not.toHaveBeenCalled()
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
    const warning = 'The following files were added without tests: <a href=\'https://github.com/instructure/ios/blob/master/src/path/to/file1.js\'>/src/path/to/file1.js</a>'
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
