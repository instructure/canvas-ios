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
