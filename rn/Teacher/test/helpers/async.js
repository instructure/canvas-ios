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
    let sync
    if (action.payload && action.payload.syncToNative) {
      sync = Promise.resolve()
      NativeModules.CoreDataSync.syncAction = jest.fn(() => sync)
    }
    await promise
    if (sync) {
      await sync
    }
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
    let sync
    if (promise.syncToNative) {
      sync = Promise.resolve()
      NativeModules.CoreDataSync.syncAction = jest.fn(() => sync)
    }
    await promise
    if (sync) {
      await sync
    }
  } catch (e) {}
  return store.getActions()
}
