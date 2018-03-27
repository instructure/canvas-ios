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

// @flow

import { isFSA } from 'flux-standard-action'
import type { Middleware, MiddlewareAPI, Dispatch } from 'redux'
import { AsyncActionTracker } from '../actions/async-tracker'
import { NativeModules } from 'react-native'
import { isStudent } from '../../modules/app'

let { pending, resolved, rejected } = AsyncActionTracker

export type Action = {
  type: string,
  payload: any,
  pending?: boolean,
  error?: boolean,
}

function isPromise (val: any): boolean {
  return val && typeof val.then === 'function'
}

let tracksAsyncActions = true
export function shouldTrackAsyncActions (should: boolean): void {
  tracksAsyncActions = should
}

/*
 * Simple middleware heavily based of off redux-promise for handling FSA
 * promises:
 *
 *   - When a FSA action is received with a payload that is a promise, or with
 *     a payload with a `promise` member, the action is tagged with a
 *     `pending: true` field.
 *   - When the attached promise resolves, a copy of the action is re-dispatched
 *     with its `payload` set to the promised value.
 *   - When the attached promise rejects, a copy of the action is re-dispatched
 *     with its `payload` set to the error, and the `error: true` tag.
 *
 */
let promiseMiddleware = <S, A: Action>({ dispatch }: MiddlewareAPI<S, A>): Middleware<S, A> => {
  return (next: Dispatch<A>) => (action: A) => {
    let promise = action.payload && action.payload.promise
    if (isFSA(action) && isPromise(promise) && !action.error) {
      promise.then(
        async (result) => {
          let payload = { ...action.payload, result }
          delete payload.promise
          if (isStudent() && action.payload.syncToNative) {
            await NativeModules.CoreDataSync.syncAction({
              type: action.type,
              payload,
            })
          }
          if (tracksAsyncActions) dispatch(resolved(action.type))
          return dispatch({ ...action, payload })
        },
        error => {
          let payload = { ...action.payload, error }
          if (tracksAsyncActions) dispatch(rejected(action.type, error))
          return dispatch({ ...action, payload, error: true })
        }
      )
      if (tracksAsyncActions) dispatch(pending(action.type))
      next({
        ...action,
        pending: true,
      })
    } else {
      next(action)
    }
  }
}

export default promiseMiddleware
