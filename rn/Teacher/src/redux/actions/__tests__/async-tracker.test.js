//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/* @flow */

import { asyncTTLCheck, asyncChecker, AsyncActionTracker, asyncActions as reducer } from '../async-tracker'

const { resolved, pending, rejected } = AsyncActionTracker

describe('asyncChecker', () => {
  test('return true when they are pending', () => {
    const state = {
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
    }

    const result = asyncChecker(state, Object.keys(state.asyncActions))
    expect(result).toBeTruthy()
  })
})

describe('asyncTTLCheck', () => {
  test('return true when the ttl has passed', () => {
    const state = {
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
    }

    const result = asyncTTLCheck(state, Object.keys(state.asyncActions), 50)
    expect(result).toBeTruthy()
  })

  test('return false when the ttl has not passed', () => {
    const state = {
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
    }

    const result = asyncTTLCheck(state, Object.keys(state.asyncActions), 50)
    expect(result).toBeFalsy()
  })

  test('return false when the ttl has not passed', () => {
    const state = {
      asyncActions: {
        'action1': {
          pending: 0,
          total: 0,
        },
      },
    }

    const result = asyncTTLCheck(state, ['action1'], 50)
    expect(result).toBeTruthy()
  })

  test('return false when the ttl has not passed', () => {
    const state = {
      asyncActions: {},
    }

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
