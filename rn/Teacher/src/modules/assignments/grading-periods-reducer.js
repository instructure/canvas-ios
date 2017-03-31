import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from '../courses/actions'
import handleAsync from '../../utils/handleAsync'
import AssignmentActions from './actions'

export let defaultState: GradingPeriodsState = {}

const { refreshGradingPeriods } = Actions
const { refreshAssignmentList } = AssignmentActions

export const gradingPeriods: Reducer<AssignmentListState, any> = handleActions({
  [refreshGradingPeriods.toString()]: handleAsync({
    resolved: (state, { result: { data: { grading_periods } } }) => {
      let newState = grading_periods.reduce((current, gradingPeriod) => {
        let existingGradingPeriod = state[gradingPeriod.id]
        return {
          ...current,
          [gradingPeriod.id]: {
            gradingPeriod,
            assignmentRefs: existingGradingPeriod ? existingGradingPeriod.assignmentRefs : [],
          },
        }
      }, {})
      return newState
    },
  }),

  [refreshAssignmentList.toString()]: handleAsync({
    resolved: (state, { result, gradingPeriodID }) => {
      if (gradingPeriodID == null) return state

      return {
        ...state,
        [gradingPeriodID]: {
          ...state[gradingPeriodID],
          assignmentRefs: result.data.reduce((current, assignmentGroup) => {
            return current.concat(assignmentGroup.assignments.map(({ id }) => id))
          }, []),
        },
      }
    },
  }),
}, defaultState)
