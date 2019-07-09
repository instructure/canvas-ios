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
