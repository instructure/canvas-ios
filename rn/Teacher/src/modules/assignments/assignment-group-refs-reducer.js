// @flow

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import { default as QuizDetailsActions } from '../quizzes/details/actions'
import CourseActions from '../courses/actions'
import handleAsync from '../../utils/handleAsync'
import i18n from 'format-message'

export let defaultState: AssignmentGroupsState = {}

const { refreshAssignmentList } = Actions
const { refreshGradingPeriods } = CourseActions
const { refreshQuiz } = QuizDetailsActions

export const assignmentGroups: Reducer<AsyncRefs, any> = handleActions({
  [refreshAssignmentList.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state, { result, courseID, gradingPeriodID }) => {
      let newState = {
        ...state,
        pending: state.pending - 1,
      }

      if (gradingPeriodID == null) {
        newState.refs = result.data.map((group) => group.id)
      }

      return newState
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
  [refreshGradingPeriods.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state) => ({ ...state, pending: state.pending - 1 }),
    rejected: (state) => ({ ...state, pending: state.pending - 1 }),
  }),
  [refreshQuiz.toString()]: handleAsync({
    resolved: (state, { result: [assignmentGroups] }) => ({
      ...state,
      refs: assignmentGroups.data.map(a => a.id),
    }),
  }),
}, { refs: [], pending: 0 })
