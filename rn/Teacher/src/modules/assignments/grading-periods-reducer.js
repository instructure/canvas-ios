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
import Actions from '../courses/actions'
import handleAsync from '../../utils/handleAsync'
import AssignmentActions from './actions'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import i18n from 'format-message'

export let defaultState: GradingPeriodsState = {}

const { refreshGradingPeriods } = Actions
const { refreshAssignmentList } = AssignmentActions

export const refs: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshGradingPeriods.toString(),
  i18n('There was a problem loading the grading periods.'),
  ({ result }) => result.data.grading_periods.map(gp => gp.id)
)

export const gradingPeriods: Reducer<any, any> = handleActions({
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
