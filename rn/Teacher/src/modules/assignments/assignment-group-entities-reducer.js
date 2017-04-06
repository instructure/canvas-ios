/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import handleAsync from '../../utils/handleAsync'

export let defaultState: AssignmentGroupsState = {}

const { refreshAssignmentList } = Actions

export const assignmentGroups: Reducer<AssignmentGroupsState, any> = handleActions({
  [refreshAssignmentList.toString()]: handleAsync({
    resolved: (state, { result, courseID, gradingPeriodID }) => {
      if (gradingPeriodID != null) return state

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
