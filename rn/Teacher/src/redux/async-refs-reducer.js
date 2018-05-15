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

import { Reducer, Action } from 'redux'
import { handleActions } from 'redux-actions'
import handleAsync from '../utils/handleAsync'
import { parseErrorMessage } from '../redux/middleware/error-handler'

export const defaultRefs: AsyncRefs = { refs: [], pending: 0 }

export function asyncRefsReducer (
  // the name of action to reduce
  actionName: string,
  // localized descriptive error message for failures
  errorMessage: string,
  // list of entity ids
  updatedRefs: (any) => ?Array<string>
): Reducer<AsyncRefs, Action> {
  return handleActions({
    [actionName]: handleAsync({
      pending: (state) => ({ ...state, pending: state.pending + 1 }),
      resolved: (state, result) => {
        let refs: Array<string> = updatedRefs(result) || state.refs
        const pending = Math.max(state.pending - 1, 0)

        let next
        if (result.result) {
          next = result.result.next
        }

        if (result.usedNext) {
          refs = [...new Set([...state.refs, ...refs])]
        }

        return { pending, refs, next }
      },
      rejected: (state, { error }) => {
        const pending = Math.max(state.pending - 1, 0)
        let message = errorMessage
        let reason = parseErrorMessage(error)
        if (reason) {
          message =
`${message}

${reason}`
        }
        return { ...state, pending, error: message }
      },
    }),
  }, defaultRefs)
}
