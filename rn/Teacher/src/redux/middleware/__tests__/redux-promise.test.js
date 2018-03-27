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

import mockStore from '../../../../test/helpers/mockStore'
import { NativeModules } from 'react-native'
import app from '../../../modules/app'

const { CoreDataSync } = NativeModules

describe('promise middleware', () => {
  beforeEach(() => {
    app.setCurrentApp('teacher')
  })

  it('does nothing with a "normal" payload', async () => {
    let store = mockStore()
    store.dispatch({ type: 'test', payload: 'plain jane' })

    expect(store.getActions()).toMatchObject([
      { type: 'test', payload: 'plain jane' },
    ])
  })

  it('immediately dispatches pending', async () => {
    let promise = new Promise(() => {})

    let store = mockStore()
    store.dispatch({ type: 'test', payload: { promise } })

    expect(store.getActions()).toMatchObject([
      { type: 'test', pending: true },
    ])
  })

  it('dispatches on resolution', async () => {
    let _resolve = (v: any) => {}
    let promise = new Promise((resolve) => { _resolve = resolve })

    let store = mockStore()
    store.dispatch({ type: 'test', payload: { promise, id: 1 } })

    _resolve('yay')
    await promise // kick the event loop

    expect(store.getActions()).toMatchObject([
      { type: 'test', pending: true, payload: { id: 1 } },
      { type: 'test', payload: { result: 'yay', id: 1 } },
    ])
  })

  it('dispatches on rejection', async () => {
    let error = new Error()
    let promise = Promise.reject(error)

    let store = mockStore()
    store.dispatch({ type: 'test', payload: { id: 1, promise } })

    try {
      await promise
    } catch (e) {}

    expect(store.getActions()).toMatchObject([
      {
        type: 'test',
        pending: true,
        payload: {
          id: 1,
          promise,
        },
      },
      {
        type: 'test',
        payload: {
          id: 1,
          error,
        },
        error: true,
      },
    ])
  })

  it('syncs to core data on resolution in Student', async () => {
    app.setCurrentApp('student')
    let spy = jest.fn()
    CoreDataSync.syncAction = spy
    let _resolve = (v: any) => {}
    let promise = new Promise((resolve) => { _resolve = resolve })

    let store = mockStore()
    store.dispatch({ type: 'test', payload: { promise, id: 1, syncToNative: true } })

    _resolve('yay')
    await promise // kick the event loop

    expect(spy).toHaveBeenCalledWith({
      type: 'test',
      payload: {
        id: 1,
        syncToNative: true,
        result: 'yay',
      },
    })
  })
})
