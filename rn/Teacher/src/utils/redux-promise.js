// @flow

import { isFSA } from 'flux-standard-action'
import type { MiddlewareAPI } from 'redux'

function isPromise (val: any): boolean {
  return val && typeof val.then === 'function'
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
let promiseMiddleware: MiddlewareAPI = ({ dispatch }) => {
  return next => action => {
    let promise = action.payload

    if (action.payload && action.payload.promise) {
      promise = action.payload.promise
    }

    if (isFSA(action) && isPromise(promise) && !action.error) {
      promise.then(
        result => dispatch({ ...action, payload: result }),
        error => dispatch({ ...action, payload: error, error: true })
      )

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
