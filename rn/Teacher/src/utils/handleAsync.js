// @flow

/*
 * Defines an action handler specifically geared for FSA async actions generated
 * by promiseMiddleware. Handlers is a dictionary with three optional values:
 *
 *  - pending: reducer that is run when the promise is first created
 *  - resolved: reducer that is called when the promise is resolved with the
 *    promised value.
 *  - rejected: reducer that is called when the promise is rejected with the
 *    thrown error.
 *
 */

import type { Reducer } from 'redux'
import type { Action } from './redux-promise'

type Handlers<S, A> = {
  pending?: Reducer<S, A>,
  rejected?: Reducer<S, A>,
  resolved?: Reducer<S, A>,
}

export default <S, A: Action>(handlers: Handlers<S, A>): Reducer<S, A> =>
  (state: S, action: Action) => {
    if (action.pending) {
      if (handlers.pending) {
        return handlers.pending(state, action.payload)
      }
    } else if (action.error) {
      if (handlers.rejected) {
        return handlers.rejected(state, action.payload)
      }
    } else {
      if (handlers.resolved) {
        return handlers.resolved(state, action.payload)
      }
    }

    return state
  }
