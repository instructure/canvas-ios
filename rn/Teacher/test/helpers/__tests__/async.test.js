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
