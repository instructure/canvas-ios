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

/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import { default as QuizDetailsActions } from '../quizzes/details/actions'
import handleAsync from '../../utils/handleAsync'

export let defaultState: AssignmentGroupsState = {}

const { refreshAssignmentList } = Actions
const { refreshQuiz } = QuizDetailsActions

export const assignmentGroups: Reducer<AssignmentGroupsState, any> = handleActions({
  [refreshAssignmentList.toString()]: handleAsync({
    resolved: (state, { result, courseID, gradingPeriodID }) => {
      if (gradingPeriodID != null) return state

      let entities = {}
      result.data.forEach((group) => {
        let assignmentRefs = (group.assignments || []).map((a) => { return a.id })
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
  [refreshQuiz.toString()]: handleAsync({
    resolved: (state, { result: [quiz, assignmentGroups] }) => {
      const incoming = assignmentGroups.data
        .reduce((incoming, group) => ({
          ...incoming,
          [group.id]: {
            ...state[group.id],
            group: {
              ...(state[group.id] && state[group.id].group),
              ...group,
            },
          },
        }), {})

      return { ...state, ...incoming }
    },
  }),
}, defaultState)
