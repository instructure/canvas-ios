//
// Copyright (C) 2017-present Instructure, Inc.
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

// @flow

import clearCache from '../clear-cache'
import {
  CachesDirectoryPath,
} from 'react-native-fs'
import {
  NativeModules,
  AsyncStorage,
} from 'react-native'
import fs from 'react-native-fs'

jest.mock('react-native-fs', () => ({
  CachesDirectoryPath: 'caches',
  exists: jest.fn(() => Promise.resolve(false)),
  mkdir: jest.fn(() => Promise.resolve()),
  unlink: jest.fn(() => Promise.resolve()),
}))

jest.mock('AsyncStorage', () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
}))

describe('clearCache', () => {
  beforeEach(() => {
    jest.resetAllMocks()
  })

  it('deletes cache directory', async () => {
    fs.exists = jest.fn(() => Promise.resolve(true))
    await clearCache()
    expect(fs.unlink).toHaveBeenCalledWith(CachesDirectoryPath)
    expect(fs.mkdir).toHaveBeenCalledWith(CachesDirectoryPath)
  })

  it('does not delete cache directory last date set', async () => {
    fs.exists = jest.fn(() => Promise.resolve(true))
    AsyncStorage.getItem = jest.fn(() => Promise.resolve(null))
    await clearCache()
    AsyncStorage.getItem = jest.fn(() => Promise.resolve(Date()))
    await clearCache()
    expect(fs.unlink).toHaveBeenCalledTimes(1)
  })

  it('creates cache directory if it doesnt exist', async () => {
    fs.exists = jest.fn(() => Promise.resolve(false))
    await clearCache()
    expect(fs.unlink).not.toHaveBeenCalled()
    expect(fs.mkdir).toHaveBeenCalledWith(CachesDirectoryPath)
  })
})

