// @flow

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import handleAsync from '../../utils/handleAsync'

export let defaultState: AssignmentGroupsState = {}

const { refreshAssignmentList, updateAssignment } = Actions

export const assignments: Reducer<AssignmentsState, any> = handleActions({
  [refreshAssignmentList.toString()]: handleAsync({
    resolved: (state, { result, courseID }) => {
      let entities = { ...state.assignments }
      result.data.forEach((entity) => {
        entity.assignments.forEach(assignment => {
          entities[assignment.id] = { assignment }
        })
      })

      return {
        ...state,
        ...entities,
      }
    },
  }),
  [updateAssignment.toString()]: handleAsync({
    pending: (state, { updatedAssignment, originalAssignment }) => {
      let id = updatedAssignment.id
      let entity = { ...state[id] }
      entity.assignment = updatedAssignment
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
      entity.assignment = originalAssignment
      entity.pending = (entity.pending || 0) - 1
      entity.error = error
      return {
        ...state,
        ...{ [id]: entity },
      }
    },
  }),
}, defaultState)
