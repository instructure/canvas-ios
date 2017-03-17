/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import type { AssignmentDetailsState } from './props'
import handleAsync from '../../utils/handleAsync'
import i18n from 'format-message'

export let defaultState: { assignmentDetails: any, pending: number, nextPage: ?Function } = { assignmentDetails: {}, pending: 0, nextPage: null }

const { refreshAssignmentDetails } = Actions

const reducer: Reducer<AssignmentDetailsState, any> = handleActions({
  [refreshAssignmentDetails.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state, response) => {
      return {
        ...state,
        pending: state.pending - 1,
        assignmentDetails: response.data,
      }
    },
    rejected: (state, response) => {
      let errorMessage = i18n('Could not get assignment list')
      return {
        ...state,
        error: errorMessage,
        pending: state.pending - 1,
      }
    },
  }),
}, defaultState)

export default reducer
