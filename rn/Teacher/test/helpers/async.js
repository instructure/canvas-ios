/* @flow */
import { createStore, applyMiddleware } from 'redux'
import promiseMiddleware from '../../src/utils/redux-promise'
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
