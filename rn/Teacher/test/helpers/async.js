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
import { NativeModules } from 'react-native'
import { createStore, applyMiddleware } from 'redux'
import promiseMiddleware from '../../src/redux/middleware/redux-promise'
import freeze from 'redux-freeze'
import mockStore from './mockStore'

/*
 * Dispatches the action on a store created with the reducer and returns an
 * array containing first the state of the store after the action is dispatched
 * and finally the state of the store after the async action is awaited.
 *
 *  - reducer: reducer under test
 *  - action: an async action
 *
 *  - returns: an array containing the state after the action is dispatched (pending)
 *  and the state after the async action is awaited (resolved or rejected).
 */

export async function testAsyncReducer<R> (reducer: R, action: any, defaultState?: any): Promise<any[]> {
  let states = []
  const store = createStore(reducer, defaultState, applyMiddleware(promiseMiddleware, freeze))
  store.dispatch(action)
  states.push(store.getState())
  try {
    let promise = action.payload && action.payload.promise ? action.payload.promise : action.payload
    await promise
  } catch (e) {}
  states.push(store.getState())
  return states
}

/*
 * Dispatches the action on a mock store then awaits the async action and returns
 * all the actions taken on the store.
 *
 *  - action: an async action
 *  - defaultState: the default state of the store
 *
 *  - returns: an array of actions (store.getActions()) after the async action
 *  has been dispatched and awaited.
 */

export async function testAsyncAction (action: any, defaultState: any): Promise<any[]> {
  const store = mockStore()
  store.dispatch(action)
  try {
    let promise = action.payload && action.payload.promise ? action.payload.promise : action.payload
    await promise
  } catch (e) {}
  return store.getActions()
}
