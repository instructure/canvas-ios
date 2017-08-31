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
import type { Action } from '../redux/middleware/redux-promise'

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
