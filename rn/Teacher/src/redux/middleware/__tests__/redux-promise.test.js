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
