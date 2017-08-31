//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

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
    resolved: (state, { result: [quiz, assignmentGroups] }) => ({
      ...state,
      refs: assignmentGroups.data.map(a => a.id),
    }),
  }),
}, { refs: [], pending: 0 })
