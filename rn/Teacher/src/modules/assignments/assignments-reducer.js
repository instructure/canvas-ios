/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import type { AssignmentListState } from './map-state-to-props'
import handleAsync from '../../utils/handleAsync'
import i18n from 'format-message'

export let defaultState: AssignmentGroupsState = {}

const { refreshAssignmentList } = Actions

export const assignmentGroups: Reducer<AssignmentListState, any> = handleActions({
  [refreshAssignmentList.toString()]: handleAsync({
    resolved: (state, { result, courseID }) => {
      let entities = state.assignmentGroupEntities || {}
      result.data.forEach((entity) => {
        entities[entity.id] = entity
      })

      return {
        ...state,
        ...entities,
      }
    },
  }),
}, defaultState)

export const assignments: Reducer<AssignmentListState, any> = handleActions({
  [refreshAssignmentList.toString()]: handleAsync({
    resolved: (state, { result, courseID }) => {
      let entities = state.assignments || {}
      result.data.forEach((entity) => {
        entity.assignments.forEach(assignment => {
          entities[assignment.id] = assignment
        })
      })

      return {
        ...state,
        ...entities,
      }
    },
  }),
}, defaultState)

export let refDefaultState: AssignmentGroupsRefState = { refs: [], pending: 0 }

export const assignmentGroupRefs: Reducer<AssignmentListState, any> = handleActions({
  [refreshAssignmentList.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state, { result, courseID }) => {
      let refs = result.data.map((group) => group.id)

      return {
        ...state,
        refs,
        pending: state.pending - 1,
      }
    },
    rejected: (state, response) => {
      let errorMessage = i18n('Could not get list of assignments')
      return {
        ...state,
        error: errorMessage,
        pending: state.pending - 1,
      }
    },
  }),
}, refDefaultState)
