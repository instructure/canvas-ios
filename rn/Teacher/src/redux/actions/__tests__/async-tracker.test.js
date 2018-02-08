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

import { asyncTTLCheck, asyncChecker, AsyncActionTracker, asyncActions as reducer } from '../async-tracker'

const { resolved, pending, rejected } = AsyncActionTracker

const template = {
  ...require('../../__templates__/app-state'),
}

describe('asyncChecker', () => {
  test('return true when they are pending', () => {
    const state = template.appState({
      asyncActions: {
        'action1': {
          pending: 0,
          total: 0,
        },
        'action2': {
          pending: 1,
          total: 0,
        },
      },
    })

    const result = asyncChecker(state, Object.keys(state.asyncActions))
    expect(result).toBeTruthy()
  })
})

describe('asyncTTLCheck', () => {
  test('return true when the ttl has passed', () => {
    const state = template.appState({
      asyncActions: {
        'action1': {
          pending: 0,
          total: 0,
          lastResolvedDate: (new Date()) - 100,
        },
        'action2': {
          pending: 0,
          total: 0,
          lastResolvedDate: (new Date()) - 5,
        },
        'action3': {
          pending: 0,
          total: 0,
          lastResolvedDate: (new Date()) - 45,
        },
        'action4': {
          pending: 0,
          total: 0,
          lastResolvedDate: (new Date()) - 10,
        },
      },
    })

    const result = asyncTTLCheck(state, Object.keys(state.asyncActions), 50)
    expect(result).toBeTruthy()
  })

  test('return false when the ttl has not passed', () => {
    const state = template.appState({
      asyncActions: {
        'action1': {
          pending: 0,
          total: 0,
          lastResolvedDate: (new Date()) - 10,
        },
        'action2': {
          pending: 0,
          total: 0,
          lastResolvedDate: (new Date()) - 5,
        },
        'action3': {
          pending: 0,
          total: 0,
          lastResolvedDate: (new Date()) - 15,
        },
        'action4': {
          pending: 0,
          total: 0,
          lastResolvedDate: (new Date()) - 30,
        },
        'action5': {
          pending: 0,
          total: 0,
          lastResolvedDate: (new Date()) - 3,
        },
      },
    })

    const result = asyncTTLCheck(state, Object.keys(state.asyncActions), 50)
    expect(result).toBeFalsy()
  })

  test('return false when the ttl has not passed', () => {
    const state = template.appState({
      asyncActions: {
        'action1': {
          pending: 0,
          total: 0,
        },
      },
    })

    const result = asyncTTLCheck(state, ['action1'], 50)
    expect(result).toBeTruthy()
  })

  test('return false when the ttl has not passed', () => {
    const state = template.appState({
      asyncActions: {},
    })

    const result = asyncTTLCheck(state, ['action1'], 50)
    expect(result).toBeTruthy()
  })
})

describe('actions', () => {
  it('pending', () => {
    const name = 'action-name'
    const test = pending(name)
    expect(test.type).toEqual('async-action.pending')
    expect(test.payload).toMatchObject({ name })
  })

  it('rejected', () => {
    const name = 'action-name'
    const error = 'error'
    const test = rejected(name, error)
    expect(test.type).toEqual('async-action.rejected')
    expect(test.payload).toMatchObject({ name, error })
  })

  it('resolved', () => {
    const name = 'action-name'
    const test = resolved(name)
    expect(test.type).toEqual('async-action.resolved')
    expect(test.payload).toMatchObject({ name })
  })
})

describe('reducer', () => {
  it('pending then resolved', () => {
    const name = 'action-name'
    let action = pending(name)
    let test = reducer({}, action)
    expect(test).toMatchObject({
      [name]: { pending: 1, total: 1 },
    })

    action = resolved(name)
    test = reducer(test, action)
    expect(test).toMatchObject({
      [name]: { pending: 0, total: 1 },
    })
    expect(test[name].lastResolvedDate).toBeDefined()
  })

  it('pending then rejected then pending then resolved', () => {
    const name = 'action-name'
    const lastError = 'error'
    let action = pending(name)
    let test = reducer({}, action)
    expect(test).toMatchObject({
      [name]: { pending: 1, total: 1 },
    })

    action = rejected(name, lastError)
    test = reducer(test, action)
    expect(test).toMatchObject({
      [name]: { pending: 0, total: 1, lastError },
    })

    action = pending(name)
    test = reducer(test, action)
    expect(test).toMatchObject({
      [name]: { pending: 1, total: 2 },
    })
    expect(test[name].lastError).not.toBeDefined()

    action = resolved(name)
    test = reducer(test, action)
    expect(test).toMatchObject({
      [name]: { pending: 0, total: 2 },
    })
    expect(test[name].lastError).not.toBeDefined()
  })
})
