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

// @flow

import { AsyncStorage } from 'react-native'
import mockStore from '../../../../test/helpers/mockStore'
import { hydrateStoreFromPersistedState } from '../persist'

jest.mock('AsyncStorage', () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  getAllKeys: jest.fn(),
  multiRemove: jest.fn(),
}))

let wait = () => new Promise(resolve => setTimeout(resolve, 1))

describe('persistMiddleware', () => {
  let store

  beforeEach(() => {
    jest.resetAllMocks()
    store = mockStore()
  })

  it('persists into async storage', async () => {
    store.dispatch({
      type: 'action',
      payload: {},
    })

    await wait()
    expect(AsyncStorage.setItem).toHaveBeenCalled()
  })

  it('removes old states', async () => {
    AsyncStorage.getItem = jest.fn(() => null)
    AsyncStorage.getAllKeys = jest.fn(() => {
      return ['redux.state.1.0', 'redux.state.0.0', 'something-else']
    })
    AsyncStorage.multiRemove = jest.fn()
    AsyncStorage.setItem = jest.fn()
    store.dispatch({
      type: 'action',
      payload: {},
    })

    await hydrateStoreFromPersistedState(store)
    expect(AsyncStorage.multiRemove).toHaveBeenCalledWith([
      'redux.state.1.0',
      'redux.state.0.0',
    ])
  })
})
