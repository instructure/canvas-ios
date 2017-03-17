/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import type { AssignmentListState } from './props'
import handleAsync from '../../utils/handleAsync'
import i18n from 'format-message'

export let defaultState: { assignmentGroups: AssignmentGroup[], pending: number, nextPage: ?Function } = { assignmentGroups: [], pending: 0, nextPage: null }

const { refreshAssignmentList } = Actions

const reducer: Reducer<AssignmentListState, any> = handleActions({
  [refreshAssignmentList.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state, paginatedResponse) => {
      const assignmentGroups = [...state.assignmentGroups, ...paginatedResponse.data].sort((a, b) => a.position - b.position)
      return {
        ...state,
        pending: state.pending - 1,
        assignmentGroups,
        nextPage: paginatedResponse.next,
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
