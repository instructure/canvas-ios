// @flow

import { Reducer, combineReducers } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import handleAsync from '../../utils/handleAsync'
import { submissions } from '../submissions/list/submission-refs-reducer'
import flatMap from 'lodash/flatMap'
import fromPairs from 'lodash/fromPairs'

export let defaultState: AssignmentGroupsState = {}

const { refreshAssignmentList, updateAssignment } = Actions

const assignment = assignment => assignment || {}
const pending = pending => pending || 0
const error = error => error || null

const assignmentContent = combineReducers({
  assignment,
  submissions,
  pending,
  error,
})

const defaultAssignmentContents: AssignmentContentState = {
  submissions: { refs: [], pending: 0 },
}

const assignmentsData: Reducer<AssignmentsState, any> = handleActions({
  [refreshAssignmentList.toString()]: handleAsync({
    resolved: (state, { result, courseID }) => {
      const assignments = flatMap(result.data, group => group.assignments)
      const updated = fromPairs(assignments.map(assignment => {
        return [
          assignment.id, {
            ...defaultAssignmentContents,
            ...state[assignment.id],
            data: assignment,
          },
        ]
      }))

      return {
        ...state,
        ...updated,
      }
    },
  }),
  [updateAssignment.toString()]: handleAsync({
    pending: (state, { updatedAssignment, originalAssignment }) => {
      let id = updatedAssignment.id
      let entity = { ...state[id] }
      entity.data = updatedAssignment
      entity.pending = (entity.pending || 0) + 1
      return {
        ...state,
        ...{ [id]: entity },
      }
    },
    resolved: (state, { updatedAssignment, originalAssignment }) => {
      let id = updatedAssignment.id
      let entity = { ...state[id] }
      entity.pending--
      return {
        ...state,
        ...{ [id]: entity },
      }
    },
    rejected: (state, { updatedAssignment, originalAssignment, error }) => {
      let id = originalAssignment.id
      let entity = { ...state[id] }
      entity.data = originalAssignment
      entity.pending = (entity.pending || 0) - 1
      entity.error = error
      return {
        ...state,
        ...{ [id]: entity },
      }
    },
  }),
}, defaultState)

export function assignments (state: AssignmentsState = {}, action: any): AssignmentDetailState {
  let newState = state
  if (action.payload && action.payload.assignmentID) {
    const assignmentID = action.payload.assignmentID
    const currentAssignmentState: AssignmentDetailState = state[assignmentID] || {}
    const assignmentState = assignmentContent(currentAssignmentState, action)
    newState = {
      ...state,
      [assignmentID]: assignmentState,
    }
  }
  return assignmentsData(newState, action)
}
