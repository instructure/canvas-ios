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

/* @flow */

import { Reducer } from 'redux'
import { handleActions, createAction } from 'redux-actions'
import handleAsync from '../../../src/utils/handleAsync'
import { testAsyncReducer, testAsyncAction } from '../async'

type State = {
  sets: string[],
  pending: number,
}

const resolveAction = createAction('test.async.reducer.resolved', jest.fn(() => ({
  promise: new Promise((resolve, reject) => {
    process.nextTick(() => {
      resolve('foo')
    })
  }),
})))

const rejectAction = createAction('test.async.reducer.rejected', jest.fn(() => ({
  promise: new Promise((resolve, reject) => {
    process.nextTick(() => {
      reject()
    })
  }),
})))

let defaultState: State
let reducer: Reducer<State, any>

beforeEach(() => {
  defaultState = { sets: [], pending: 0 }
  reducer = handleActions({
    [resolveAction.toString()]: handleAsync({
      pending: (state) => ({ ...state, pending: state.pending + 1 }),
      resolved: (state, n) => ({
        ...state,
        sets: state.sets.concat(n),
        pending: state.pending - 1,
      }),
    }),
    [rejectAction.toString()]: handleAsync({
      pending: (state) => ({ ...state, pending: state.pending + 1 }),
      rejected: (state, error) => ({
        ...state,
        error: 'Something bad happened.',
        pending: state.pending - 1,
      }),
    }),
  }, defaultState)
})

describe('testAsyncReducer', () => {
  it('should return pending and resolved states', async () => {
    const result = await testAsyncReducer(reducer, resolveAction())

    expect(result).toEqual([
      {
        sets: [],
        pending: 1,
      },
      {
        sets: [{ result: 'foo' }],
        pending: 0,
      },
    ])
  })

  it('should return pending and rejected states', async () => {
    const result = await testAsyncReducer(reducer, rejectAction())

    expect(result).toEqual([
      {
        sets: [],
        pending: 1,
      },
      {
        sets: [],
        pending: 0,
        error: 'Something bad happened.',
      },
    ])
  })
})

test('testAsyncAction', async () => {
  const result = await testAsyncAction(resolveAction(), defaultState)

  expect(result).toMatchObject([
    {
      type: resolveAction.toString(),
      pending: true,
    },
    {
      type: resolveAction.toString(),
      payload: { result: 'foo' },
    },
  ])
})
