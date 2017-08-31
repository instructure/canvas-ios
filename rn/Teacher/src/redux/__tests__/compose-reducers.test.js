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

import Reducer from 'redux'
import composeReducers from '../compose-reducers'

test('it works with 0... why not?', () => {
  const state = { baskets: 9, stringState: 'lethargic' }
  const reducer = composeReducers()
  expect(reducer(state)).toEqual(state)
})

test('it works with 1 reducer', () => {
  const nextState = { blah: 'blah blah' }

  let r: Reducer<any, any> = jest.fn((state, action) => {
    return nextState
  })

  const state = { blah: 'blah' }
  const action = { type: 'yo' }
  const reducer = composeReducers(r)
  expect(reducer(state, action)).toEqual(nextState)
  expect(r).toHaveBeenCalledWith(state, action)
})

test('it works with n reducers', () => {
  const finalState = { legos: 'pirate', pieces: 42 }

  let a: Reducer<any, any> = jest.fn((state, action) => {
    return { ...state, legos: 'castle', pieces: 42 }
  })

  let b: Reducer<any, any> = jest.fn((state, action) => {
    return { ...state, legos: 'pirate' }
  })

  const state = { legos: 'city' }
  const action = { type: 'yo.bricks' }
  const reducer = composeReducers(a, b)
  expect(reducer(state, action)).toEqual(finalState)
  expect(a).toHaveBeenCalledWith(state, action)
  expect(b).toHaveBeenCalledWith({ ...state, legos: 'castle', pieces: 42 }, action)
})
