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

      let entities = {}
      result.data.forEach((group) => {
        let assignmentRefs = group.assignments.map((a) => { return a.id })
        let mutableGroup = Object.assign({}, group)
        delete mutableGroup.assignments
        entities[group.id] = { group: mutableGroup, assignmentRefs }
      })

      return {
        ...state,
        ...entities,
      }
    },
  }),
}, defaultState)
