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

// @flow

import AsyncStorage from '@react-native-community/async-storage'
import mockStore from '../../../../test/helpers/mockStore'
import { hydrateStoreFromPersistedState } from '../persist'

jest.mock('@react-native-community/async-storage', () => ({
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
    jest.clearAllMocks()
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
